Feature: Examine a dish page
  In order to look at a particular dish and see infomration about it
  As a viewer
  I want to be able to see the dish info and user feedback
  
  Scenario: Examine a restaurant
  	Given I have a dish
  	When I go to that dish's page
  	Then I should see Dish1
  	And I should see No reviews
