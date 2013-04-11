class RemoveRestaurantReferenceFromDish < ActiveRecord::Migration
  def up
    remove_index :dishes, :restaurant_id
    change_table :dishes do |t|
      t.remove_belongs_to :restaurant
      t.remove_references :restaurant
    end
  end

  def down
    change_table :dishes do |t|
      t.add_belongs_to :restaurant
      t.references :restaurant
    end
    add_index :dishes, :restaurant_id
  end
end
