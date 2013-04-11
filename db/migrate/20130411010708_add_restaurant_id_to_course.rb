class AddRestaurantIdToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :restaurant_id, :integer
    add_index :courses, :restaurant_id
  end
end
