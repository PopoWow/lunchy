Feature: View the daily lineup for today
  In order to see the daily lineup for the current day
  As a viewer
  I want to be able to see the restaurants and their feedback summary
  
  Scenario: Restaurant list with feedback
  	Given I have a daily lineup for today
  	When I go to the lineup for today
  	Then I should see Establishment1, Establishment2, Establishment3, Establishment4, Establishment5, Establishment6
  	And I should see Reviews, Rating