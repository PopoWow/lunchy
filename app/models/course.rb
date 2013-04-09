class Course < ActiveRecord::Base
  has_many :dishes
  attr_accessible :description, :waiter_id
end
