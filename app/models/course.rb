class Course < ActiveRecord::Base
  has_many :dishes, :dependent => :destroy
  belongs_to :restaurant
  attr_accessible :description, :name, :waiter_id
end
