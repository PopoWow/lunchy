require 'time'
require 'debugger'
require 'mechanize'
require 'json'

require_relative 'waiter_info'

class ScraperBase
  attr_reader :data
  
  # see AGENT_ALIASES for full list of predefined with use with user_agent_alias
  # or roll your own via user_again:
  @@user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.43 Safari/537.31"

  def initialize
    @agent = Mechanize.new
    @agent.user_agent = @@user_agent
  end  
end

class WeeklyMenuData < ScraperBase
  def initialize(subdir="")
    # PWD is lunchy!  need to drill down a bit.
    @json_file = File.join(Dir.pwd, subdir, "weekly_menu.json")
    super()
  end
  
  def download_weekly_menu
    # for dev testing, load if we find a json file that has the data
   
    if FileTest.exists?(@json_file)
      load_weekly_menu
    else
      raise "foobar"
      @agent.get('http://www.waiter.com/vcs') do |login_page|
        menu_page = login_page.form_with(:action => '/user_sessions') do |login_form|
          name_field = login_form.field_with(:name => 'user_session[login]')
          name_field.value = waiter_account
          pw_field = login_form.field_with(:name => 'user_session[password]')
          pw_field.value = waiter_password
        end.submit    
      
        # login form was submitted.  We should have the menu page now.
        
        # Scrape the json text
        matches = menu_page.content.match(/carts: ({.*}),$/)
        # log error here, if matches is nil!
        
        @data = JSON.parse(matches[1])
      end

=begin      
      # save off the files to text for posterity
      f1 = open('weekly_menu.html', 'w')
      f1.write(menu_page.content)
      f1.close
      
      f2 = open('weekly_menu.json', 'w')
      f2.write(matches[1])
      f2.close
=end      
    end
  end  
  
  def load_weekly_menu
    puts "Reading json from 'weekly_menu.json'"
    f1 = open(@json_file)
    json_text = f1.read
    f1.close
    @data = JSON.parse(json_text)
  end
end

class RestaurantMenuData < ScraperBase
  def download_menu(menu_id)
    url = "https://www.waiter.com/menus/#{menu_id}.json"
    @agent.get(url) do |menu_data|
      @data = JSON.parse(menu_data.content)
    end
  end
end

# similar to python __name__ == "__main__":
if __FILE__ == $0
  this_week = WeeklyMenuData.new
  this_week.download_weekly_menu
  
  ["57", "59"].each do |earlylate|
    (1..5).each do |day|
      datestr = this_week.data[earlylate][day]["date"] # ex: "2013-04-01T11:45:00-07:00"  aha!  a ruby datetime object... hehe
      dt_for = DateTime.parse(datestr)
      (0..2).each do |choice|
        menu_id = this_week.data[earlylate][day]["carts"][choice]["service"]["menu_id"]
        name = this_week.data[earlylate][day]["carts"][choice]["service"]["store"]["name"]
        str_name = "%s-%s.json" % [menu_id, name]
        
        menu_obj = RestaurantMenuData.new
        menu_obj.download_menu(menu_id)
        file = open(str_name, 'w')
        file.write(JSON.pretty_generate(menu_obj.data))
        file.close
      end
    end
  end
end