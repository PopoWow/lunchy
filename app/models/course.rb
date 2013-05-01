class Course < ActiveRecord::Base
  has_many :dishes, :dependent => :destroy
  belongs_to :restaurant
  attr_protected

  #scope :published, where(:published => true).joins(:category)
  scope :active, where(:active => true).order("position")
end
