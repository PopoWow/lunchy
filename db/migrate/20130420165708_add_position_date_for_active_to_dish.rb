class AddPositionDateForActiveToDish < ActiveRecord::Migration
  def change
    add_column :dishes, :position, :integer
    add_column :dishes, :date_for, :date
    add_column :dishes, :active, :boolean
  end
end
