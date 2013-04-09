class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.integer :waiter_id
      t.string :description

      t.timestamps
    end
  end
end
