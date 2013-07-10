Feature: View the daily lineup for today
  In order to see the daily lineup for the current day
  As a viewer
  I want to be able to see the restaurants and their feedback summary
  
  Scenario: Restaurant list with feedback
  	Given I have a daily lineup for today
  	When I go to the lineup for today
  	Then I should see Restaurant1, Restaurant2, Restaurant3, Restaurant4, Restaurant5, Restaurant6
  	And I should see Reviews, Rating
  	
  Scenario: Look at today's popular dishes
  	Given I have a lineup with restaurants that have dishes that have ratings
  	When I go to the lineup for today
  	Then I should see Popular Dishes
	# popular dishes showing top 3 dishes...
  	And I should see Rated1, Rated2, Rated3
	And I should not see Rated4, Rated5, Rated5
  	
  Scenario: See that there are no popular dishes
    Given I have a lineup with restaurants that have no dishes with ratings
    When I go to the lineup for today
    Then I should see not see Popular Dishes
   