class Course < ActiveRecord::Base
  has_many :dishes
  belongs_to :restaurant
  attr_accessible :description, :name, :waiter_id
end
