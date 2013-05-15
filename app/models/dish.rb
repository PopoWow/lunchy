class Dish < ActiveRecord::Base
  belongs_to :course

  # polymorphic thus :as.  Not inversable
  has_many :reviews, :as => :reviewable

  attr_protected

  scope :active, where(:active => true).order("position")

  def restaurant
    # helper to add easy access to owning restaurant from this model.
    # does this cause two queries?  Look into Eager Loading multiple assoc.
    # http://guides.rubyonrails.org/active_record_querying.html#eager-loading-multiple-associations
    course.restaurant
  end
end
