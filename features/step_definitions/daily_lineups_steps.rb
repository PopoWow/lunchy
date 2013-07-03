

Given(/^I have a daily lineup for today$/) do
  FactoryGirl.create(:daily_lineup_with_schedulings_and_restaurants)
end

When(/^I go to the lineup for today$/) do
  visit root_path
end

=begin
Then(/^I should see the following restaurants?: (.*)$/) do |restaurants|
  #save_and_open_page
  restaurants.split(', ').each do |restaurant|
    #debugger
    page.should have_content(restaurant)
  end
end
=end

Then(/^I should see:? (.*)$/) do |args|
  args.split(', ').each do |arg|
    #debugger
    page.should have_content(arg)
  end
end

Given(/^I have a lineup with restaurants that have dishes that have ratings$/) do
  user = FactoryGirl.create(:user)
  lineup = FactoryGirl.create(:daily_lineup_with_schedulings_and_restaurants)

  rests = [lineup.restaurants.first, lineup.restaurants.last]
  rests.each_with_index do |restaurant, ndx|
    course = FactoryGirl.create(:course, :restaurant => restaurant, :name => "Course#{ndx}")
    dish = FactoryGirl.create(:dish, :course => course, :name => "Rated#{ndx}")
    rating = FactoryGirl.create(:rating, :value => 5 - ndx, :user => user,
                                :ratable_type => 'Restaurant', :ratable => restaurant)
  end
end

Given(/^I have a lineup with restaurants that have no dishes with ratings$/) do
  user = FactoryGirl.create(:user)
  lineup = FactoryGirl.create(:daily_lineup_with_schedulings_and_restaurants)

  rests = [lineup.restaurants.first, lineup.restaurants.last]
  rests.each_with_index do |restaurant, ndx|
    course = FactoryGirl.create(:course, :restaurant => restaurant, :name => "Course#{ndx}")
    dish = FactoryGirl.create(:dish, :course => course, :name => "Rated#{ndx}")
  end
end