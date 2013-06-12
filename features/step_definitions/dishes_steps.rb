Given(/^I have a dish( with review(s)?)?$/) do |review, plural|
  @dish = FactoryGirl.create(:dish_with_course)
end

When(/^I go to that dish's page$/) do
  visit dish_path(@dish)
  #save_and_open_page
end
