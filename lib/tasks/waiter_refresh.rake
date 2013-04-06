namespace :waiter do
  task :refresh => :environment do
    desc "Scrape waiter.com and refresh menu lineup for the week"
    puts "Refreshing restaurant lineup for the week"
  end
end
