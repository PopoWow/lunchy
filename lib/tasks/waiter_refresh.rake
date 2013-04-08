require 'time'
require_relative 'waiter_scrape'

namespace :waiter do
  task :refresh => :environment do
    desc "Scrape waiter.com and refresh menu lineup for the week"
    puts "Refreshing restaurant lineup for the week"
      
    weekly_lineup = WeeklyMenuData.new
    weekly_lineup.download_weekly_menu
    
    ["57", "59"].each do |earlylate|
      (1..5).each do |day|
        datestr = weekly_lineup.data[earlylate][day]["date"] # ex: "2013-04-01T11:45:00-07:00"  aha!  a ruby datetime object... hehe
        dt_for = DateTime.parse(datestr)
        (0..2).each do |choice|
          menu_id = weekly_lineup.data[earlylate][day]["carts"][choice]["service"]["menu_id"]
          name = weekly_lineup.data[earlylate][day]["carts"][choice]["service"]["store"]["name"]
          puts "%s - %s - %s" % [dt_for.to_s, menu_id, name]
          # str_name = "%s-%s.json" % [menu_id, name]          
          # menu_obj = RestaurantMenuData.new
          # menu_obj.download_menu(menu_id)
          # file = open(str_name, 'w')
          # file.write(JSON.pretty_generate(menu_obj.data))
          # file.close
          
          menu = RestaurantMenuData.new
          #menu.download_menu(menu_id)
        end
      end
    end

  end
end
