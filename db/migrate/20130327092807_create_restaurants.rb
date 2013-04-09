# up/down vs. change
# http://stackoverflow.com/questions/10365129/rails-migrations-self-up-and-self-down-versus-change
# http://guides.rubyonrails.org/migrations.html#using-the-change-method

class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      # Available column types:
      #     :string, :text, :integer, :float, :decimal, :datetime,
      #     :timestamp, :time, :date, :binary, :boolean
      t.integer :waiter_id
      t.string :name
      t.string :address
      t.string :food_type # could be multiple.  
                          # Concat into one string for informational purposes only.
                          # i.e. not queryable.
      t.binary :logo_image # store image as binary data OR
      t.string :logo_url   # perhaps just store URL but I kinda want to just store it once.
      
      # Add fields that let Rails automatically keep track
      # of when movies are added or modified:
      t.timestamps
    end
  end
end
