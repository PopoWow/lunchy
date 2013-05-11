class ChangeNamesToText < ActiveRecord::Migration
  # some course names are longer than 255 chars!
  def up
    change_column :courses, :name, :text, :limit => nil
  end

  def down
    change_column :courses, :name, :string
  end
end
