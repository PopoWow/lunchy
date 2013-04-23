require 'time'
require 'mechanize'
require 'json'
require 'action_view'

######################################################################
# ScraperBase: Base class for scraper classes.  Handles the grunt
# =>           work of mechanize

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
    #record.touch don't modify updated_at field anymore.  Using date_for to track activity.
    record.update_attributes(new_info)
  end
end

######################################################################
# WeeklyMenuData: Pulls waiter.com weekly menu lineup and populates
#                 DB if needed.

class WeeklyMenuData < ScraperBase

  # make the json analysis code more readable
  EARLY = "57"; LATE = "59" # 57 = early lunch, 59 = late lunch.  Yep.
  MONDAY = 1; FRIDAY = 5
  FIRST_CHOICE = 0; LAST_CHOICE = 2

  # path to the saved weekly lineup json files
  LINEUPS_PATH = Rails.root.join("tmp/waiter/lineups") 

  DEBUG = true
  
  def download_and_populate_db_in_stages
    # download lineup + all restaurant menu information and save locally as
    # .json files.

    if DEBUG
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
        name_field.value = WAITER_INFO[:account]
        pw_field = login_form.field_with(:name => 'user_session[password]')
        pw_field.value = WAITER_INFO[:password]
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

    file_path = File.join(LINEUPS_PATH, "lineup_#{Time.now.utc.to_s}.json").gsub(":", "-")
    File.open(file_path, "w") do |outfile|
      outfile.puts(JSON.pretty_generate(@data))
    end
  end

  def download_menus
    # iterate through the restaurants for the week and download those.
    # save into a hash to populate DB later.
    @menus = {}
    [EARLY, LATE].each do |earlylate|
      (MONDAY..FRIDAY).each do |day|
        (FIRST_CHOICE..LAST_CHOICE).each do |choice|
          menu_id = @data[earlylate][day]["carts"][choice]["service"]["menu_id"]
          name = @data[earlylate][day]["carts"][choice]["service"]["store"]["name"]
          
          puts "Downloading menu for restaurant: #{name}"
          @menus[menu_id] = RestaurantMenuData.new
          @menus[menu_id].download_menu(menu_id)
        end
      end
    end
  end

  ## Processing data
  
  def process_weekly_lineup_data
    # as we iterate over the data, collate it into this hash, ordered by day,
    # so we can just rip through it at the end and create daily_lineup records.
    ordered_by_date = {}

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
          restaurant_desc = restaurant_menu.get_description

          # create or update the restaurant record
          new_restaurant = create_restaurant(rest_hash, restaurant_desc)

          # we now have menu data for the current restaurant
          # and a restaurant record to belong to.
          restaurant_menu.date_for = date_for
          restaurant_menu.process_courses_and_dishes(new_restaurant)

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
    waiter_id = rest_hash["service"]["store"]["id"].to_int
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
    [EARLY, LATE].each do |earlylate|
      (MONDAY..FRIDAY).each do |day|
        (FIRST_CHOICE..LAST_CHOICE).each do |choice|
          id = @data[earlylate][day]["carts"][choice]["service"]["id"]
          name = @data[earlylate][day]["carts"][choice]["service"]["store"]["name"]          
          puts "Downloading menu for restaurant: #{id}-#{name}"
        end
      end
    end        
  end
  
  def update_active_flags
    #courses = Course.all
    #courses.each 
  end
  
  def update_course_averages
    courses = Course.all
    courses.each
  end
  
end

######################################################################
# RestaurantMenuData: Pulls menu for a specific restaurant and
#                     create course/dish info for it.

class RestaurantMenuData < ScraperBase
  include ActionView::Helpers::SanitizeHelper
  
  attr_accessor :date_for

  def download_menu(menu_id)
    # need to use mechanize here... simple http get does not work.
    url = "https://www.waiter.com/menus/#{menu_id}.json"
    @agent.get(url) do |menu_data|
      @data = JSON.parse(menu_data.content)
    end
  end

  def get_description
    # see if we can find a usable desc.

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

  def process_courses_and_dishes(restaurant_parent)
    # we can create course/meal objects from this
    @data["menu_sections"].each do |menu_course|
      new_course = create_course(restaurant_parent, menu_course)

      if new_course
        # Thought about putting this in create_course but I don't like
        # nesting this behavior within that one.
        # Iterate through dishes for this course.
        menu_course["menu_items"].each do |dish|
          create_dish(new_course, dish)
        end
      end
    end
  end

  def create_course(restaurant, course_info)
    course_name = course_info["name"]
    if course_name.include? "EMPLOYEE USE ONLY"
      # hardcoded to ignore this anomalous one
      return
    end

    if course_info["menu_items"].empty?
      # no menu items, this is strictly informational

      # Okay, some of these restaurants are sneaking the name into one of
      # these parts and then having the name of the courses as more like
      # a description.  See 7651-Bangkok Bay.  So, save this off so it might
      # be used by a later iteration.
      @saved_course_name = course_name
      return
    end

    if course_name.length > 80 and # 80 sounds good... but this is clearly a guess
                                   @saved_course_name then
      # in this case where the name is very long and we have a saved course name,
      # assume that the actual course name is the saved one.
      course_name = @saved_course_name
    end

    #only keep saved around for first iteration
    @saved_course_name = nil

    waiter_id = course_info["id"]
    course_desc = course_info["description"]
    position = course_info["position"]

    course_hash = {:waiter_id => waiter_id,
                   :name => course_name,
                   :description => course_desc,
                   :position => position}

    new_course = restaurant.courses.find_or_create_by_waiter_id(waiter_id)
    
    # only update date_for if it's later than the current one.  This is
    # for the edge case where a restaurant is specified twice for a week.
    # Not even sure if this would ever happen in a production environment.
    if new_course.date_for and new_course.date_for < @date_for
      course_hash[:date_for] = @date_for
    end
    
    ScraperBase.log_and_update_record(new_course, course_hash)

    return new_course
  end

  def create_dish(course, dish_info)
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

    new_dish = course.dishes.find_or_create_by_waiter_id(waiter_id)
    
    # only update date_for if it's later than the current one.  This is
    # for the edge case where a restaurant is specified twice for a week.
    # Not even sure if this would ever happen in a production environment.
    if new_dish.date_for and new_dish.date_for < @date_for
      dish_hash[:date_for] = @date_for
    end
    
    ScraperBase.log_and_update_record(new_dish, dish_hash)
  end
end

# similar to python __name__ == "__main__":
if __FILE__ == $0
  weekly_lineup = WeeklyMenuData.new()
  weekly_lineup.load_weekly_lineup_file
  weekly_lineup.dump_names
end