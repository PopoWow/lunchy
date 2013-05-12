class DailyLineup < ActiveRecord::Base
  has_many :schedulings, :order => [:shift, :position]
  has_many :restaurants, :through => :schedulings,
           :order => [:shift, :position]

  attr_protected
end
