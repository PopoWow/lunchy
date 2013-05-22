class Restaurant < ActiveRecord::Base
  # associations to DailyLineup
  has_many :schedulings
  has_many :daily_lineups, :through => :schedulings,
           :order => :date

# associations to Course/Dish
  has_many :courses, :inverse_of => :restaurant, :dependent => :destroy
  has_many :active_courses, :class_name => 'Course',
           :conditions => ['active = ?', true], :order => :position

  has_many :dishes, :through => :courses

  # polymorphic thus :as.  Not inversable
  has_many :reviews, :as => :reviewable
=begin
  has_many :reviews_for_user, :as => :reviewable, :class => 'Review',
           :conditions => ['user_id = ?', current_user]
=end

  # association to rating
  has_many :ratings, :as => :ratable

  #scope :rating, lambda {|user| ratings.where("user_id = ?", user.id) }


  #scope :active_courses_dishes_reviews, courses.where("active = ?", true).order(:position).includes(:dishes => :reviews)

  # exper.
  # has_many :sent_private_messages, :class_name => 'PrivateMessage', :foreign_key => 'sender_id'
  # has_many :received_private_messages, :class_name => 'PrivateMessage', :foreign_key => 'recipient_id'

  def star_rating
    # to round to the nearest half star
    #(val * 2).round / 2.0

    ratings.where("value != '0'").average(:value).to_f.round(1)
  end

  attr_protected
end
