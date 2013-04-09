class CreateDishes < ActiveRecord::Migration
  def change
    create_table :dishes do |t|
      t.integer :waiter_id
      t.string :name
      t.string :description
      t.float :price
      t.references :restaurant
      t.references :course

      t.timestamps
    end
    add_index :dishes, :restaurant_id
    add_index :dishes, :course_id
  end
end
