$:.unshift File.join(File.dirname(__FILE__), "waiter")

require 'waiter_scrape'

namespace :waiter do
  task :refresh => :environment do
    desc "Scrape waiter.com and refresh menu lineup for the week"

    weekly_lineup = WeeklyMenuData.new()
    weekly_lineup.download_lineup_and_populate_db
  end
end
