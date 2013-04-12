class Dish < ActiveRecord::Base
  belongs_to :course  
  attr_protected
  
  def restaurant
    # helper to add easy access to owning restaurant from this model.
    # does this cause two queries?  Look into Eager Loading multiple assoc.
    # http://guides.rubyonrails.org/active_record_querying.html#eager-loading-multiple-associations
    course.restaurant
  end
end
