

Given(/^I have a daily lineup for today$/) do
  @lineup = FactoryGirl.create(:daily_lineup_with_schedulings_and_restaurants)
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
