require 'time'
require_relative 'waiter_scrape'

namespace :waiter do
  task :refresh => :environment do
    desc "Scrape waiter.com and refresh menu lineup for the week"
    puts "Refreshing restaurant lineup for the week"
      
    weekly_lineup = WeeklyMenuData.new("lib/tasks")
    weekly_lineup.download_weekly_menu
    
    # 57 = early lunch, 59 = late lunch.  Yep.
    ["57", "59"].each do |earlylate|
      (1..5).each do |day|
        datestr = weekly_lineup.data[earlylate][day]["date"] # ex: "2013-04-01T11:45:00-07:00"  aha!  a ruby datetime object... hehe
        dt_for = DateTime.parse(datestr)
        (0..2).each do |choice|
          # gather restaurant info for model 
          rest_hash = weekly_lineup.data[earlylate][day]["carts"][choice] # this is each resaurants hash data.

          # menu description needs to be pulled from restaurant specific json
          menu_id = rest_hash["service"]["menu_id"]
          menu = RestaurantMenuData.new
          menu.download_menu(menu_id)
          
          # see if we can find a usable desc.
          first_rest_item = menu.data["menu_sections"][0]
          rest_desc = get_restaurant_description(first_rest_item)
          
          # create or update the restaurant record
          new_restaurant = create_restaurant(rest_hash, rest_desc)
          
          # we now have menu data for the current restaurant.
          # we can create course/meal objects from this
          menu.data["menu_sections"].each do |menu_course|            
            create_course(new_restaurant, menu_course)
          end
        end
      end
    end
  end
  
  def create_restaurant(rest_hash, description)
    # tons of choices here but picking this one since it's next to the name
    waiter_id = rest_hash["service"]["store"]["id"].to_int
    name = rest_hash["service"]["store"]["name"]
    address = rest_hash["service"]["store"]["address"]["label"]
    food_type = rest_hash["service"]["store"]["restaurant"]["food_types"].join(" / ")
    logo_url = rest_hash["service"]["store"]["restaurant"]["logo_url"]
    
    rec_hash = {:name => name,
                :address => address,
                :food_type => food_type,
                :logo_url => logo_url,
                :description => description}
    
    restaurant = Restaurant.find_or_create_by_waiter_id(waiter_id)
    return ensure_record_up_to_date(restaurant, rec_hash)
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
      course_name = @saved_course_name       
    end
    
    #only keep saved around for first iteration
    @saved_course_name = nil    
    
    waiter_id = course_info["id"]
    course_desc = course_info["description"]
    
    course_hash = {:waiter_id => waiter_id,
                   :name => course_name,
                   :description => course_desc}

    new_course = restaurant.courses.find_or_create_by_waiter_id(waiter_id)
    ensure_record_up_to_date(new_course, course_hash)
    
    # iterate through dishes for this menu.
    course_info["menu_items"].each do |dish|
      create_dish(new_course, dish)      
    end
  end
  
  def create_dish(course, dish_info)
    waiter_id = dish_info["id"]
    name = dish_info["name"]
    description = dish_info["description"]
    price = dish_info["formatted_price"]
    f_price = price.to_f
    
    dish_hash = {:waiter_id => waiter_id,
                 :name => name,
                 :description => description,
                 :price => f_price}
                 
    new_dish = course.dishes.find_or_create_by_waiter_id(waiter_id)
    ensure_record_up_to_date(new_dish, dish_hash)
  end
  
  def get_restaurant_description(rest_item)
    unless rest_item["menu_items"].empty?
      # the menu_items array has something in it so it's not
      # a "descriptive" item.
      return ""
    end
    
    unless rest_item["description"]
      rest_item["description"] = ""
    end
    unless rest_item["name"]
      rest_item["name"] = ""
    end
      
    # no menu items.  This is a descriptive item.  First the largest
    # between the name/desc and use it if it's over, say, 50 chars
    potential_desc = rest_item["description"].length > rest_item["name"].length ?
                        rest_item["description"] : rest_item["name"]
    rest_desc = potential_desc.length > 50 ? potential_desc : ""                              
  end
  
  # find a way to add this to a new class?  perhaps record_updater class?
  def ensure_record_up_to_date(record, new_info)
    changed = false
    new_info.each do |key, val|      
      if record[key] != val # convert all record values to string for comparison
        puts 'value for :%s changing from "%s" to "%s"' % [key, record[key], val].map{|item| item.to_s}
        record[key] = val
        changed = true
      end
    end
    if changed
      record.save!
    end
    
    return record
  end    
end
