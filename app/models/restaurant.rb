class Restaurant < ActiveRecord::Base
  has_many :courses, :dependent => :destroy
  has_many :dishes, :through => :courses
  attr_accessible :address, :description, :food_type, :logo_image, :logo_url, :name, :waiter_id
end
