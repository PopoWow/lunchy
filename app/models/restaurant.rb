class Restaurant < ActiveRecord::Base
  # associations to DailyLineup
  has_many :schedulings
  has_many :daily_lineups, :through => :schedulings,
           :order => :date

# associations to Course/Dish
  has_many :courses, :dependent => :destroy
  has_many :dishes, :through => :courses

  has_many :active_courses, :class_name => 'Course',
           :conditions => ['active = ?', true], :order => :position

  # exper.
  # has_many :sent_private_messages, :class_name => 'PrivateMessage', :foreign_key => 'sender_id'
  # has_many :received_private_messages, :class_name => 'PrivateMessage', :foreign_key => 'recipient_id'

  attr_protected
end
