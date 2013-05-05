class User < ActiveRecord::Base
  authenticates_with_sorcery!
  # attr_accessible :title, :body

  # from railscast
  attr_accessible :nickname, :email, :password, :password_confirmation

  validates_length_of :password, :minimum => 3, :message => "password must be at least 3 characters long", :if => :password
  validates_confirmation_of :password, :message => "should match confirmation", :if => :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_presence_of :nickname
  validates_uniqueness_of :nickname
end
