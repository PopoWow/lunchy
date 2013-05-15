class Review < ActiveRecord::Base
  belongs_to :reviewable, :polymorphic => true # Polymorphic, thus not inversable
  belongs_to :user, :inverse_of => :reviews

  attr_accessible :title, :content

  # not using anymore but could be useful FFR
  #scope :reviews, scoped

  validates_presence_of :title, :content, :reviewable_id, :reviewable_type, :user_id
=begin
  validates_uniqueness_of :user_id, :scope => [:reviewable_id, :reviewable_type],
                          :message => "user already has a review for this item"
=end
end
