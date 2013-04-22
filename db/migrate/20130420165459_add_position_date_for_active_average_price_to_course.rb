class AddPositionDateForActiveAveragePriceToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :position, :integer
    add_column :courses, :date_for, :date
    add_column :courses, :active, :boolean
    add_column :courses, :average_price, :float
  end
end
