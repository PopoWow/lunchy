class Restaurant < ActiveRecord::Base
  has_many :dishes
  attr_accessible :address, :description, :food_type, :logo_image, :logo_url, :name, :waiter_id
end
