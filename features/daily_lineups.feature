Feature: View the daily lineup for today
  In order to see the daily lineup for the current day
  As a viewer
  I want to be able to see the restaurants and their feedback summary
  
  Scenario: Restaurant list with feedback
  	Given I have a daily lineup for today
  	When I go to the lineup for today
  	Then I should see Establishment1, Establishment2, Establishment3, Establishment4, Establishment5, Establishment6
  	And I should see Reviews, Rating
  	
Feature: View popular dishes for the day
  In order to get suggestions for a tasty dish to eat
  As a viewer
  I want to be able to see a lineup, for today or a specific date, and see popular dishes
  
  Scenario: Look at today's menu and look for popular dishes
  	Given I have a lineup 