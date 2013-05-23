class Rating < ActiveRecord::Base
  belongs_to :ratable, :polymorphic => true, :touch => true
  belongs_to :user, :inverse_of => :ratings

  scope :for_user, lambda {|user| where("user_id = ?", user.id) }

  attr_accessible :value

  validates_presence_of :value, :user_id, :ratable_id, :ratable_type
  validates_inclusion_of :value, :in => (1..5)
  validates_uniqueness_of :user_id, :scope => [:ratable_id, :ratable_type],
                          :message => "user already has a rating for this item"
end
