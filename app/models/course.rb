class Course < ActiveRecord::Base
  has_many :dishes
  has_one :restaurant, through => :dishes
  attr_accessible :description, :name, :waiter_id
end
