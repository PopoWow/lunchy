class ChangeDescriptionsToText < ActiveRecord::Migration
  def up
    change_column :restaurants, :description, :text, :limit => nil
    change_column :courses, :description, :text, :limit => nil
    change_column :dishes, :description, :text, :limit => nil
  end

  def down
    change_column :dishes, :description, :string
    change_column :courses, :description, :string
    change_column :restaurants, :description, :string
  end
end
