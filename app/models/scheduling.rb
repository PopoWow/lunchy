class Scheduling < ActiveRecord::Base
  belongs_to :daily_lineup
  belongs_to :restaurant

  #attr_accessible :shift, :position
  validates_uniqueness_of :daily_lineup_id, :scope => :restaurant_id,
                          :message => "can only have one restaurant assigned"
end
