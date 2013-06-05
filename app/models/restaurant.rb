class Restaurant < ActiveRecord::Base
  include Feedbackable

  # associations to DailyLineup
  has_many :schedulings, :inverse_of => :restaurant
  has_many :daily_lineups, :through => :schedulings, :order => :date

# associations to Course/Dish
  has_many :courses, :inverse_of => :restaurant, :dependent => :destroy
  has_many :active_courses, :class_name => 'Course', :foreign_key => :restaurant_id,
           :conditions => ['active = ?', true], :order => :position

  has_many :dishes, :through => :courses

  # polymorphic thus :as.  Not inversable
  has_many :reviews, :as => :reviewable
  has_many :ratings, :as => :ratable

  attr_protected

  #scope :rating, lambda {|user| ratings.where("user_id = ?", user.id) }
  #scope :active_courses_dishes_reviews, courses.where("active = ?", true).order(:position).includes(:dishes => :reviews)

  # exper.
  # has_many :sent_private_messages, :class_name => 'PrivateMessage', :foreign_key => 'sender_id'
  # has_many :received_private_messages, :class_name => 'PrivateMessage', :foreign_key => 'recipient_id'
end
