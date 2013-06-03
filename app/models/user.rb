class User < ActiveRecord::Base
  authenticates_with_sorcery!

  has_many :reviews, :inverse_of => :user
  has_many :ratings, :inverse_of => :user
  has_many :reviewed_dishes, :through => :reviews, :source => :reviewable, :source_type => 'Dish'
  has_many :rated_dishes, :through => :ratings, :source => :ratable, :source_type => 'Dish'
  has_many :reviewed_restaurants, :through => :reviews, :source => :reviewable, :source_type => 'Restaurant'
  has_many :rated_restaurants, :through => :ratings, :source => :ratable, :source_type => 'Restaurant'

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






  def get_review(reviewable_object)
    if reviewable_object.respond_to? :id
      reviews.where("reviews.reviewable_id = ? AND reviews.reviewable_type = ?",
                    reviewable_object.id, reviewable_object.class.to_s).
              first
    end
  end

  def get_review_info(reviewable_object, field)
    review = get_review(reviewable_object)
    if review and review.respond_to? field
      review.send(field)
    end
  end

  def get_rating(ratable_object)
    if ratable_object.respond_to? :id
      ratings.where("ratings.ratable_id = ? AND ratings.ratable_type = ?",
                    ratable_object.id, ratable_object.class.to_s).
              first
    end
  end

  def get_rating_info(ratable_object, field)
    rating = get_rating(ratable_object)
    if rating and rating.respond_to? field
      rating.send(field)
    end
  end

=begin
  def get_restaurant_review(restaurant_id)
    reviews.where("reviews.reviewable_id = ? AND reviews.reviewable_type = 'Restaurant'", restaurant_id).first
  end

  def get_restaurant_rating(restaurant_id)
    ratings.where("ratings.ratable_id = ? AND ratings.ratable_type = 'Restaurant'", restaurant_id).first
  end

  def get_restaurant_review_id(restaurant_id)
    review = get_restaurant_review(restaurant_id)
    if review
      review.id
    end
  end
=end

end
