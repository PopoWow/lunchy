$:.unshift File.join(File.dirname(__FILE__), "waiter")

require 'waiter_scrape'
require 'waiter_prune'

namespace :waiter do
  task :refresh => :environment do
    desc "Scrape waiter.com and refresh menu lineup for the week"

    weekly_lineup = WeeklyMenuData.new()
    #weekly_lineup.download_lineup_and_populate_db

    # to make this more robust, going to do this in two stages.
    # First, try to download all the weekly data and save into .json files.
    # If all files are downloaded correctly, then start parsing them.
    # Before I was downloading and parsing linearly so if an error
    # happens in the middle, you're kinda in an intermediate state.

    weekly_lineup.download_and_populate_db_in_stages
  end
end
