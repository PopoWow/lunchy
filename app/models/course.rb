class Course < ActiveRecord::Base
  has_many :dishes, :dependent => :destroy
  belongs_to :restaurant
  attr_protected
end
