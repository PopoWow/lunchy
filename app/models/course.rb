class Course < ActiveRecord::Base
  has_many :dishes
  attr_accessible :description, :name, :waiter_id
end
