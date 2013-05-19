class User < ActiveRecord::Base
  authenticates_with_sorcery!

  has_many :reviews, :inverse_of => :user

  # attr_accessible :title, :body

  # from railscast
  attr_accessible :nickname, :email, :password, :password_confirmation

  validates_length_of :password, :minimum => 3, :message => "password must be at least 3 characters long", :if => :password
  validates_confirmation_of :password, :message => "should match confirmation", :if => :password
  validates_presence_of :email
  validates_uniqueness_of :email, :case_sensitive => false
  validates_presence_of :nickname
  validates_uniqueness_of :nickname, :case_sensitive => false
  validates_presence_of :password, :on => :create

  def resend
    send_activation_needed_email!
  end

  def check_password(password)
    self.class.send :credentials_match?, send(sorcery_config.crypted_password_attribute_name), password, salt
  end

  def set_new_hashed_password(new_password)
    self.send :"#{sorcery_config.password_attribute_name}=", new_password
  end
end
