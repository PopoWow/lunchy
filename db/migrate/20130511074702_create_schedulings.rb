class CreateSchedulings < ActiveRecord::Migration
  SLOT_1 = 1
  SLOT_2 = 2
  SLOT_3 = 3
  EARLY = 1
  LATE = 2

  def up
    create_table :schedulings, :id => false do |t|
      t.references :daily_lineup
      t.references :restaurant
      t.integer :position
      t.integer :shift # as in early shift, late shift
      t.timestamps
    end
    add_index :schedulings, :daily_lineup_id
    add_index :schedulings, :restaurant_id

    # migrate old style records to new style
    new_schoolize_daily_lineups

    # drop old fields from daily_lineups
    drop_old_school_fields
  end

  def down
    add_old_school_fields
    old_schoolize_daily_lineups
    drop_table :schedulings
  end

  def new_schoolize_daily_lineups
    connection = ActiveRecord::Base.connection
    daily_lineups = connection.execute("select * from daily_lineups")
    daily_lineups.each do |lineup|
      insert_new_scheduling(connection, lineup["id"], lineup["early_1_id"], SLOT_1, EARLY)
      insert_new_scheduling(connection, lineup["id"], lineup["early_2_id"], SLOT_2, EARLY)
      insert_new_scheduling(connection, lineup["id"], lineup["early_3_id"], SLOT_3, EARLY)
      insert_new_scheduling(connection, lineup["id"], lineup["late_1_id"], SLOT_1, LATE)
      insert_new_scheduling(connection, lineup["id"], lineup["late_2_id"], SLOT_2, LATE)
      insert_new_scheduling(connection, lineup["id"], lineup["late_3_id"], SLOT_3, LATE)
    end
  end

  def insert_new_scheduling(connection, lineup_id, restaurant_id, slot, type)
    str_time = Time.now.to_s(:db)
    connection.execute(%Q[INSERT INTO schedulings
                          VALUES (#{lineup_id}, #{restaurant_id}, #{slot}, #{type},
                                  '#{str_time}', '#{str_time}')])
  end

  def old_schoolize_daily_lineups
    connection = ActiveRecord::Base.connection
    lineup_ids = connection.execute(
      %Q[SELECT DISTINCT daily_lineup_id FROM schedulings])
    lineup_ids_a = lineup_ids.to_a.collect! {|item| item["daily_lineup_id"]}
    lineup_ids_a.each do |lineup_id|
      rest_ids = connection.execute(%Q[SELECT restaurant_id FROM schedulings
                                       WHERE (daily_lineup_id = #{lineup_id})
                                       ORDER BY shift, position])
      rest_ids_a = rest_ids.to_a.collect! {|item| item["restaurant_id"]}
      connection.execute(
        %Q[UPDATE daily_lineups
           SET early_1_id = #{rest_ids_a[0]}, early_2_id = #{rest_ids_a[1]}, early_3_id = #{rest_ids_a[2]},
               late_1_id = #{rest_ids_a[3]}, late_2_id = #{rest_ids_a[4]}, late_3_id = #{rest_ids_a[5]}
           WHERE id = #{lineup_id}])
    end
  end

  def drop_old_school_fields
    change_table :daily_lineups do |t|
      t.remove :early_1_id
      t.remove :early_2_id
      t.remove :early_3_id
      t.remove :late_1_id
      t.remove :late_2_id
      t.remove :late_3_id
    end
  end

  def add_old_school_fields
    change_table :daily_lineups do |t|
      t.references :early_1
      t.references :early_2
      t.references :early_3
      t.references :late_1
      t.references :late_2
      t.references :late_3
    end
    add_index :daily_lineups, :early_1_id
    add_index :daily_lineups, :early_2_id
    add_index :daily_lineups, :early_3_id
    add_index :daily_lineups, :late_1_id
    add_index :daily_lineups, :late_2_id
    add_index :daily_lineups, :late_3_id
  end
end
