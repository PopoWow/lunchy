class Restaurant < ActiveRecord::Base
  has_many :dishes
  has_many :courses, :through => :dishes
  attr_accessible :address, :description, :food_type, :logo_image, :logo_url, :name, :waiter_id
end
