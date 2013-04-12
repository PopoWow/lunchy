class CreateDailyLineups < ActiveRecord::Migration
  def change
    create_table :daily_lineups do |t|
      t.date :date
      t.references :early_1
      t.references :early_2
      t.references :early_3
      t.references :late_1
      t.references :late_2
      t.references :late_3

      t.timestamps
    end
    add_index :daily_lineups, :early_1_id
    add_index :daily_lineups, :early_2_id
    add_index :daily_lineups, :early_3_id
    add_index :daily_lineups, :late_1_id
    add_index :daily_lineups, :late_2_id
    add_index :daily_lineups, :late_3_id
  end
end
