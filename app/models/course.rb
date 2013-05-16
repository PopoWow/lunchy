class Course < ActiveRecord::Base
  has_many :dishes, :dependent => :destroy

  # this allows you to eager load dishes properly when getting active courses.
  # ex: @restaurant.active_courses.includes(:active_dishes).each do |course|
  #       course.active_dishes.each {|dish| dish.name}
  #     end
  has_many :active_dishes, :class_name => 'Dish',
           :conditions => ['active = ?', true], :order => :position

  belongs_to :restaurant, :inverse_of => :courses

  attr_protected

  # abandoning in favor of association above
  #scope :active, where(:active => true).order("position")
end
