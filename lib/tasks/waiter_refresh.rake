require 'time'
require_relative 'waiter_scrape'

namespace :waiter do
  task :refresh => :environment do
    desc "Scrape waiter.com and refresh menu lineup for the week"
    puts "Refreshing restaurant lineup for the week"
      
    weekly_lineup = WeeklyMenuData.new("lib/tasks")
    weekly_lineup.download_weekly_menu
    
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

          create_restaurant(rest_hash, menu.data["menu_sections"][0]["description"])
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
    ensure_record_up_to_date(restaurant, rec_hash)
    end
  end
  
  def create_course(course_info)
    
  end
  
  # find a way to add this to a new class?  perhaps record_updater class?
  def ensure_record_up_to_date(record, new_info)
    changed = false
    new_info.each do |key, val|
      if record[key] != val
        puts 'value for :%s changing from "%s" to "%s"' % [key.to_s, record[key], val]
        record[key] = val
        changed = true
      end
    end
    if changed
      record.save!
  end    
end
