class Restaurant < ActiveRecord::Base
  has_many :courses, :dependent => :destroy
  has_many :dishes, :through => :courses
  # has_many :sent_private_messages, :class_name => 'PrivateMessage', :foreign_key => 'sender_id'
  # has_many :received_private_messages, :class_name => 'PrivateMessage', :foreign_key => 'recipient_id'

  attr_protected
end
