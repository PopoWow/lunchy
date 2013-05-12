class Scheduling < ActiveRecord::Base
  belongs_to :daily_lineup
  belongs_to :restaurant

  # attr_accessible :title, :body
end
