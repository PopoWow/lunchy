class Restaurant < ActiveRecord::Base
  # associations to DailyLineup
  has_many :schedulings
  has_many :daily_lineups, :through => :schedulings,
           :order => :date

# associations to Course/Dish
  has_many :courses, :inverse_of => :restaurant, :dependent => :destroy
  has_many :dishes, :through => :courses

  has_many :active_courses, :class_name => 'Course',
           :conditions => ['active = ?', true], :order => :position

  # polymorphic thus :as.  Not inversable
  has_many :reviews, :as => :reviewable

  #scope :active_courses_dishes_reviews, courses.where("active = ?", true).order(:position).includes(:dishes => :reviews)

  # exper.
  # has_many :sent_private_messages, :class_name => 'PrivateMessage', :foreign_key => 'sender_id'
  # has_many :received_private_messages, :class_name => 'PrivateMessage', :foreign_key => 'recipient_id'

  attr_protected
end
