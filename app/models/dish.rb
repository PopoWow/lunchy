class Dish < ActiveRecord::Base
  include Feedbackable

  belongs_to :course

  #delegate :restaurant, :to => :course, :allow_nil => true
  has_one :restaurant, :through => :course

  # polymorphic thus :as.  Not inversable
  has_many :reviews, :as => :reviewable
  has_many :ratings, :as => :ratable

  has_many :review_users, :through => :reviews, :source => :user
  has_many :rating_users, :through => :ratings, :source => :user

  attr_protected
end
