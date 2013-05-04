require 'time'
require 'mechanize'
require 'json'
require 'action_view'

LINEUP_DEBUG = true
MENU_DEBUG = true

######################################################################
######################################################################
# ScraperBase: Base class for scraper classes.  Handles the grunt
# =>           work of mechanize
######################################################################
######################################################################

class ScraperBase
  # see AGENT_ALIASES for full list of predefined with use with user_agent_alias
  # or roll your own via user_agent:
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.43 Safari/537.31"

  def initialize
    @agent = Mechanize.new
    @agent.user_agent = USER_AGENT
  end

  # find a way to add this to a new class?  perhaps record_updater class?
  def self.log_and_update_record(record, new_info)
    new_info.each do |key, val|
      if record[key] != val # convert all record values to string for comparison
        puts 'value for :%s changing from "%s" to "%s"' % [key, record[key], val].map{|item| item.to_s}
      end
    end
    record.update_attributes(new_info)
  end
end

######################################################################
######################################################################
# WeeklyMenuData: Pulls waiter.com weekly menu lineup and populates
#                 DB if needed.
######################################################################
######################################################################

class WeeklyMenuData < ScraperBase

  # make the json analysis code more readable
  EARLY = "57"; LATE = "59" # 57 = early lunch, 59 = late lunch.  Yep.
  MONDAY = 1; FRIDAY = 5
  FIRST_CHOICE = 0; LAST_CHOICE = 2

  # path to the saved weekly lineup json files
  LINEUPS_PATH = Rails.root.join("tmp/waiter/lineups")

  def download_and_populate_db_in_stages
    # download lineup + all restaurant menu information and save locally as
    # .json files.

    if LINEUP_DEBUG
      # if we're running in debug mode, skip download stage and just
      # use last version of downloaded lineup

      load_weekly_lineup_file
    else
      # First check and see if there's the possibility of updated items
      last_lineup = DailyLineup.select(:date).order("date DESC").first
      if last_lineup
        if Date.today <= last_lineup.date
          # nothing to do, we're still up to date.
          puts "Menus already up to date"
          return
        end
      end

      download_and_save_weekly_lineup_file
    end

    # so no @data should have parsed lineup info.  Use that to
    # download the individual restaurant menus.
    download_menus

    # if we're here, then all menu data has been downloaded into memory.  Process it.
    process_weekly_lineup_data
  end

  # testing code, so i don't have to hammer away at waiter.com w/ account info.
  def load_weekly_lineup_file
    puts "Refreshing restaurant lineup for the week (from local .json)"

    lineup_files = Dir.glob(File.join(LINEUPS_PATH, "lineup_*.json"))
    if lineup_files.empty?
      download_and_save_weekly_lineup_file
    else
      open(lineup_files.last, "r") do |lineup_file|
        @data = JSON.parse(lineup_file.read)
      end
    end
  end

  def download_and_save_weekly_lineup_file
    puts "Refreshing restaurant lineup for the week (from waiter.com)"
    @agent.get('http://www.waiter.com/vcs') do |login_page|
      menu_page = login_page.form_with(:action => '/user_sessions') do |login_form|
        name_field = login_form.field_with(:name => 'user_session[login]')
        name_field.value = EXT_ACCOUNT[:waiter][:account]
        pw_field = login_form.field_with(:name => 'user_session[password]')
        pw_field.value = EXT_ACCOUNT[:waiter][:password]
      end.submit
      # login form was submitted.  We should have the menu page now.

      # Scrape the json object that contains all the data for the week
      matches = menu_page.content.match(/carts: ({.*}),$/)
      # log error here, if matches is nil!

      @data = JSON.parse(matches[1])

      save_weekly_lineup_file
    end
  end

  def save_weekly_lineup_file
    unless File.directory? LINEUPS_PATH
      FileUtils.mkpath(LINEUPS_PATH)
    end

    file_path = File.join(LINEUPS_PATH, "lineup_#{Time.now.utc.to_s.gsub(":", "-")}.json")
    File.open(file_path, "w") do |outfile|
      outfile.puts(JSON.pretty_generate(@data))
    end
  end

  # iterator to retrieve menus by day
  def get_service_info_by_day
    (MONDAY..FRIDAY).each do |day|
      [EARLY, LATE].each do |earlylate|
        (FIRST_CHOICE..LAST_CHOICE).each do |choice|
          yield @data[earlylate][day]["carts"][choice]["service"]
        end
      end
    end
  end

  def download_menus
    # iterate through the restaurants for the week and download those.
    # save into a hash to populate DB later.
    @menus = {}
    get_service_info_by_day do |service_info|
      menu_id = service_info["menu_id"]
      name = service_info["store"]["name"]

      puts "Downloading menu for restaurant: #{name}"
      @menus[menu_id] = RestaurantMenuData.new
      @menus[menu_id].retrieve_menu_data(menu_id)
    end
  end

  ## Processing data

  def process_weekly_lineup_data
    # as we iterate over the data, collate it into this hash, ordered by day,
    # so we can just rip through it at the end and create daily_lineup records.
    ordered_by_date = {}
    @first_day_of_week = Date.parse(@data[EARLY][MONDAY]["date"])

    # not using iterator here because I need a little flexibility to get date
    [EARLY, LATE].each do |earlylate|
      (MONDAY..FRIDAY).each do |day|

        # ex: "2013-04-01T11:45:00-07:00"  aha!  a ruby datetime object... hehe
        datestr = @data[earlylate][day]["date"]
        date_for = Date.parse(datestr)

        unless ordered_by_date[date_for]
          # This date was not found, so initialize the hash val as
          # another hash with two arrays
          ordered_by_date[date_for] = {EARLY => [], LATE => []}
        end

        (FIRST_CHOICE..LAST_CHOICE).each do |choice|
          # gather restaurant info for model
          rest_hash = @data[earlylate][day]["carts"][choice] # this is each restaurant's hash data.

          # menu description needs to be pulled from restaurant specific json
          menu_id = rest_hash["service"]["menu_id"]

          restaurant_menu = @menus[menu_id]

          # unfortunately the restaurant description is in this
          # weekly lineup data and not the json for the restaurant.
          # So, pull it out here, if possible, then pass it on.
          restaurant_desc = restaurant_menu.get_restaurant_description

          # create or update the restaurant record
          new_restaurant = create_restaurant(rest_hash, restaurant_desc)

          # we now have menu data for the current restaurant
          # and a restaurant record to belong to.
          restaurant_menu.date_for = date_for
          restaurant_menu.process_courses_and_dishes(new_restaurant)

          # now that updated courses and dishes were added we can
          # prune (mark as inactive) old ones.
          restaurant_menu.update_active_flags

          # save off restaurant id for newly created rest.  Used for
          # creating daily_lineup records later.
          ordered_by_date[date_for][earlylate] << new_restaurant.id
        end
      end
    end

    create_daily_lineup(ordered_by_date)
  end

  def create_restaurant(rest_hash, description)
    # several choices here, for "id", but picking this one since it's next to the name
    waiter_id = rest_hash["service"]["store"]["id"]
    name = rest_hash["service"]["store"]["name"]
    address = rest_hash["service"]["store"]["address"]["label"]
    food_type = rest_hash["service"]["store"]["restaurant"]["food_types"].join(" / ")
    logo_url = rest_hash["service"]["store"]["restaurant"]["logo_url"]

    puts "Processing: #{name}"

    rec_hash = {:name => name,
                :address => address,
                :food_type => food_type,
                :logo_url => logo_url,
                :description => description}

    restaurant = Restaurant.find_or_initialize_by_waiter_id(waiter_id)
    ScraperBase.log_and_update_record(restaurant, rec_hash)
    return restaurant
  end

  def create_daily_lineup(lineup_data)
    # finally, create daily_lineup record
    lineup_data.each do |date, both_lineups|
      lineup_vals = {# this can be WAY more dynamic...
                     :early_1_id => both_lineups[EARLY][0],
                     :early_2_id => both_lineups[EARLY][1],
                     :early_3_id => both_lineups[EARLY][2],
                     :late_1_id => both_lineups[LATE][0],
                     :late_2_id => both_lineups[LATE][1],
                     :late_3_id => both_lineups[LATE][2]}

      daily_lineup = DailyLineup.find_or_initialize_by_date(date)
      daily_lineup.update_attributes(lineup_vals, :without_protection => true) # saves daily_lineup
    end
  end

  def dump_names
    get_service_info_by_day do |service_info|
      id = service_info["menu_id"]
      name = service_info["store"]["name"]
      puts "Downloading menu for restaurant: #{id}-#{name}"
    end
  end

end

######################################################################
######################################################################
# RestaurantMenuData: Pulls menu for a specific restaurant and
#                     create course/dish info for it.
######################################################################
######################################################################

class RestaurantMenuData < ScraperBase
  include ActionView::Helpers::SanitizeHelper

  # path to the saved weekly lineup json files
  MENUS_PATH = Rails.root.join("tmp/waiter/menus")

  attr_accessor :date_for

  def retrieve_menu_data(menu_id)
    @file_path = File.join(MENUS_PATH, "#{menu_id}.json")

    if not MENU_DEBUG or not File.exists?(@file_path)
      # need to use mechanize here... simple http get does not work.
      url = "https://www.waiter.com/menus/#{menu_id}.json"
      puts "Download menu from #{url}"
      @agent.get(url) do |menu_data|
        @data = JSON.parse(menu_data.content)
      end

      save_weekly_menu_file
    else
      puts "Reading menu from #{@file_path}"
      File.open(@file_path, "r") do |infile|
        @data = JSON.parse(infile.read)
      end
    end
  end

  def save_weekly_menu_file
    unless File.directory? MENUS_PATH
      FileUtils.mkpath(MENUS_PATH)
    end

    File.open(@file_path, "w") do |outfile|
      outfile.puts(JSON.pretty_generate(@data))
    end
  end

  def get_restaurant_description
    # see if we can find a usable restaurant desc.

    first_rest_item = @data["menu_sections"][0]

    unless first_rest_item["menu_items"].empty?
      # the menu_items array has something in it so it's not
      # a "descriptive" item.
      return ""
    end

    # convert any nils to ""
    item_desc = first_rest_item["description"] ? first_rest_item["description"] : ""
    item_name = first_rest_item["name"] ? first_rest_item["name"] : ""

    # no menu items.  This is a descriptive item.  First the largest
    # between the name/desc and use it if it's over, say, 50 chars
    potential_desc = item_desc.length > item_name.length ?
                        item_desc : item_name

    return strip_tags(potential_desc.length > 50 ? potential_desc : "")
  end

  # enumerator function to get valid course_data
  def enumerate_courses
    saved_course_name = nil

    @data["menu_sections"].each do |course_data|

      # put any other filters here.

      course_name = course_data["name"]
      if course_name.include? "EMPLOYEE USE ONLY"
        # hardcoded to ignore this anomalous one
        next
      end

=begin
      if course_data["menu_items"].empty?
        # no menu items, this is strictly informational

        # Okay, some of these restaurants are sneaking the name into one of
        # these parts and then having the name of the courses as more like
        # a description.  See 7651-Bangkok Bay.  So, save this off so it might
        # be used by a later iteration.
        saved_course_name = course_name

        puts "Detected possible course name (empty course).  Saving: #{saved_course_name}"
        next
      end

      if course_name.length > 80 and # 80 sounds good... but this is clearly a guess
                                     saved_course_name then
        puts "Overriding #{course_name} with saved: #{saved_course_name}"

        # in this case where the name is very long and we have a saved course name,
        # assume that the actual course name is the saved one.
        course_name = saved_course_name
      end

      #only keep saved around for first iteration
      saved_course_name = nil
=end
      yield course_data
    end
  end

  def process_courses_and_dishes(restaurant_parent)
    # we can create course/meal objects from this
    @restaurant_parent = restaurant_parent

    enumerate_courses do |course_data|
      new_course = create_course(course_data)

      if new_course and not course_data["menu_items"].empty?
        # Iterate through "menu_items" and create the dishes.
        # Keep track of the prices so we can calculate the
        # average afterwards.
        price_sum = 0.0
        course_data["menu_items"].each do |dish_data|
          create_dish(new_course, dish_data)
          price_sum += dish_data["formatted_price"].to_f
        end

        # update average price for this course.  A little wasteful
        # since this course record is being saved twice so keep
        # that in mind.  Perhaps only init record in create_course
        # then assume that it will be saved here.

        # average price is used to possibly determine if courses should
        # be collapsed by default.  If the avg is, say, $30 then we can
        # be farily sure that it's something like catering trays which
        # we're not interested in.
        course_average = (price_sum / course_data["menu_items"].count).round(2)
        ScraperBase.log_and_update_record(new_course, :average_price=>course_average)
      end
    end
  end

  def create_course(course_data)
    waiter_id = course_data["id"]
    course_name = course_data["name"]
    course_desc = course_data["description"]
    position = course_data["position"]

    course_hash = {:waiter_id => waiter_id,
                   :name => course_name,
                   :description => course_desc,
                   :position => position}

    new_course = @restaurant_parent.courses.find_or_create_by_waiter_id(waiter_id)

    # only update date_for if it's later than the current one.  This is
    # for the edge case where a restaurant is specified twice for a week.
    # Not even sure if this would ever happen in a production environment.
    if new_course.date_for and new_course.date_for < @date_for
      course_hash[:date_for] = @date_for
    end

    ScraperBase.log_and_update_record(new_course, course_hash)

    return new_course
  end

  def create_dish(course_parent, dish_info)
    waiter_id = dish_info["id"]
    name = dish_info["name"]
    description = dish_info["description"]
    price = dish_info["formatted_price"].to_f
    position = dish_info["position"]

    dish_hash = {:waiter_id => waiter_id,
                 :name => name,
                 :description => description,
                 :price => price,
                 :position => position}

    new_dish = course_parent.dishes.find_or_create_by_waiter_id(waiter_id)

    # only update date_for if it's later than the current one.  This is
    # for the edge case where a restaurant is specified twice for a week.
    # Not even sure if this would ever happen in a production environment
    # because it only manifests if you run this update process twice a week.
    if new_dish.date_for and new_dish.date_for < @date_for
      dish_hash[:date_for] = @date_for
    end

    ScraperBase.log_and_update_record(new_dish, dish_hash)
  end

  def update_active_flags
    # The easiest way to detect active vs. inactive items (course) is
    # to iterate over this menu json data because it represents the
    # latest info pulled from waiter.com.  If it's referred to here
    # then it's active if not, inactive.

    # gather list of active courses/dishes
    active_course_ids = []
    active_dish_ids = []
    @data["menu_sections"].each do |course|
      active_course_ids << course["id"]
      active_dish_ids.concat(course["menu_items"].map {|dish| dish["id"]})
    end

    #puts "active courses: #{active_course_ids}"
    #puts "active dishes #{active_dish_ids}"

    # now iterate over all courses/dishes and compare against actives.
    @restaurant_parent.courses.includes(:dishes).each do |course|
      if active_course_ids.include? course.waiter_id
        mark_active(course)
      else
        mark_inactive(course)
      end

      course.dishes.each do |dish|
        if active_dish_ids.include? dish.waiter_id
          mark_active(dish)
        else
          mark_inactive(dish)
        end
      end
    end

    # once all items are properly flagged, we can then migrate
    # comments/ratings/etc to the active one if needed.
    migrate_info_from_inactive_items
  end

  # Regex to parse course/dish names to strip out any headings

  def mark_active(item)
    #puts "#{prefix}marking #{parent.name}:#{child.name} as active"
    ScraperBase.log_and_update_record(item, :active => true)
  end

  def mark_inactive(item)
    #puts "Inactive: #{dish.created_at} - #{item.class.name}:#{dish.name}"

    ScraperBase.log_and_update_record(item, :active => false)
  end

  def migrate_info_from_inactive_items
    # currently, courses do not have any information to migrate so we
    # can ignore them.
    @restaurant_parent.dishes.where(:active => false).includes(:course).each do |inactive_dish|
      qresults = find_best_match_for_inactive_dish(inactive_dish)
      if qresults.empty?
        #debugger
        puts "Could not find match for: #{inactive_dish.name}"
      else
        if qresults.count > 1
          #debugger
          puts "DETECTED MORE THAN ONE ACTIVE!"
        end
        #debugger
        #puts "Found match for inactive item: count: #{qresults[0].updated_at} #{qresults[0].name}"
      end
    end
  end

  def find_best_match_for_inactive_dish(inactive_dish)
    # Queries are case sensitive.  work around this.
    lower_dish = inactive_dish.name.downcase
    lower_course = inactive_dish.course.name.downcase

    # try for an exact match first.  Name + course name
    arel_base = Dish.joins(:course => :restaurant).order("dishes.updated_at DESC")
    qresults = arel_base.where("restaurants.id = ? AND lower(courses.name) = ? AND lower(dishes.name) = ? AND dishes.active = ?",
                               @restaurant_parent.id, lower_course, lower_dish, true).
                         all
    return qresults unless qresults.empty?

    # okay, that didn't work.  Try a LIKE but still use course name
    #   strip out any heading info, ex: "A4.", "AB10"
    match_string = inactive_dish.name.match(/(?:[A-Za-z0-9]+\.\s?)?(.+)/)[1].downcase
    like_term = "%#{match_string}%"

    qresults = arel_base.where("restaurants.id = ? AND lower(courses.name) = ? AND lower(dishes.name) LIKE ? AND dishes.active = ?",
                               @restaurant_parent.id, lower_course, like_term, true).
                         all
    unless qresults.empty?
      puts "Found fuzzy match with exact course/LIKE name (#{inactive_dish.name} vs. #{qresults[0].name}/#{like_term})"
      return qresults
    end

    # Try exact name search anywhere
    qresults = arel_base.where("restaurants.id = ? AND lower(dishes.name) = ? AND dishes.active = ?",
                               @restaurant_parent.id, lower_dish, true).
                         all
    unless qresults.empty?
      puts "Found fuzzy match with different course/exact name (#{inactive_dish.course.name} vs. #{qresults[0].course.name}/#{inactive_dish.name})"
      return qresults
    end

    # okay, last chance.  Try and find a LIKE item anywhere.
    qresults = arel_base.where("restaurants.id = ? AND lower(dishes.name) LIKE ? AND dishes.active = ?",
                               @restaurant_parent.id, like_term, true).
                         all
    unless qresults.empty?
      puts "Found fuzzy match with different course/LIKE name (#{inactive_dish.course.name} vs. #{qresults[0].course.name}/#{like_term})"
      return qresults
    end


    #puts "Count not find LIKE dish match. (#{inactive_dish.course.name}" if qresults.empty?

    return qresults
  end

end

# similar to python __name__ == "__main__":
if __FILE__ == $0
  weekly_lineup = WeeklyMenuData.new()
  weekly_lineup.load_weekly_lineup_file
  weekly_lineup.dump_names
end