class DailyLineup < ActiveRecord::Base
  belongs_to :early_1, class_name => 'Restaurant'
  belongs_to :early_2, class_name => 'Restaurant'
  belongs_to :early_3, class_name => 'Restaurant'
  belongs_to :late_1, class_name => 'Restaurant'
  belongs_to :late_2, class_name => 'Restaurant'
  belongs_to :late_3, class_name => 'Restaurant'
  attr_accessible :date
end
