$:.unshift File.join(File.dirname(__FILE__), "waiter")
$:.unshift File.join(Rails.root.join('lib/yelp'))

require 'waiter_scrape'

namespace :waiter do
  task :refresh => :environment do
    desc "Access waiter.com and refresh menu lineup for the week"

    weekly_lineup = WeeklyMenuData.new()

    # to make this more robust, going to do this in two stages.
    # First, try to download all the weekly data and save into .json files.
    # If all files are downloaded correctly, then start parsing them.
    # Before I was downloading and parsing linearly so if an error
    # happens in the middle, you're kinda in an intermediate state.

    weekly_lineup.download_and_populate_db_in_stages
  end

  task :cached => :environment do
    desc "Use cached waiter.com info to test parsing"

    weekly_lineup = WeeklyMenuData.new()
    weekly_lineup.download_and_populate_db_in_stages(true)
  end
end
