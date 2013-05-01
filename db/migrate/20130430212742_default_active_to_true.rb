class DefaultActiveToTrue < ActiveRecord::Migration
  def up
    change_column :courses, :active, :boolean, :default => true
    change_column :dishes, :active, :boolean, :default => true
  end

  def down
    # You can't currently remove default values in Rails
  end
end
