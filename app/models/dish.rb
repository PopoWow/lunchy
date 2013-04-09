class Dish < ActiveRecord::Base
  belongs_to :restaurant
  belongs_to :course
  attr_accessible :description, :name, :price, :waiter_id
end
