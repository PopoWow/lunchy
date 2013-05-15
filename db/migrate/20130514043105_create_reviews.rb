class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.string :title
      t.text :content,          :limit => nil
      t.boolean :expurgate,     :default => false
      t.references :reviewable, :polymorphic => true
      t.references :user

      t.timestamps
    end
    add_index :reviews, :reviewable_id
    add_index :reviews, :user_id
  end
end
