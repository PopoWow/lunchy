class Dish < ActiveRecord::Base
  belongs_to :course

  #delegate :restaurant, :to => :course, :allow_nil => true
  has_one :restaurant, :through => :course

  # polymorphic thus :as.  Not inversable
  has_many :reviews, :as => :reviewable
  has_many :ratings, :as => :ratable

  has_many :review_users, :through => :reviews, :source => :user
  has_many :rating_users, :through => :ratings, :source => :user

  attr_protected

  #scope :active, where(:active => true).order("position")
=begin
  convert to has_one above
  def restaurant
    # helper to add easy access to owning restaurant from this model.
    # does this cause two queries?  Look into Eager Loading multiple assoc.
    # http://guides.rubyonrails.org/active_record_querying.html#eager-loading-multiple-associations
    course.restaurant
  end
=end

  def star_rating
    # to round to the nearest half star
    #(val * 2).round / 2.0
    # is there a way to eager load this?

    ratings.where("value != '0'").average(:value).to_f.round(1)
  end

  def valid_rating_count
    ratings.where("value != '0'").count
  end
end
