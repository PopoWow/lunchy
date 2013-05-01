class DefaultActiveToTrue < ActiveRecord::Migration
  def up
    change_column :courses, :active, :boolean, :default => true
    change_column :dishes, :active, :boolean, :default => true
  end

  def down
    change_column :courses, :active, :boolean, :default => nil
    change_column :dishes, :active, :boolean, :default => nil
  end
end
