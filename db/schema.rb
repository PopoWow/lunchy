# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130412064023) do

  create_table "courses", :force => true do |t|
    t.integer  "waiter_id"
    t.string   "description"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "name"
    t.integer  "restaurant_id"
  end

  add_index "courses", ["restaurant_id"], :name => "index_courses_on_restaurant_id"

  create_table "daily_lineups", :force => true do |t|
    t.date     "date"
    t.integer  "early_1_id"
    t.integer  "early_2_id"
    t.integer  "early_3_id"
    t.integer  "late_1_id"
    t.integer  "late_2_id"
    t.integer  "late_3_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "daily_lineups", ["early_1_id"], :name => "index_daily_lineups_on_early_1_id"
  add_index "daily_lineups", ["early_2_id"], :name => "index_daily_lineups_on_early_2_id"
  add_index "daily_lineups", ["early_3_id"], :name => "index_daily_lineups_on_early_3_id"
  add_index "daily_lineups", ["late_1_id"], :name => "index_daily_lineups_on_late_1_id"
  add_index "daily_lineups", ["late_2_id"], :name => "index_daily_lineups_on_late_2_id"
  add_index "daily_lineups", ["late_3_id"], :name => "index_daily_lineups_on_late_3_id"

  create_table "dishes", :force => true do |t|
    t.integer  "waiter_id"
    t.string   "name"
    t.string   "description"
    t.float    "price"
    t.integer  "course_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "dishes", ["course_id"], :name => "index_dishes_on_course_id"

  create_table "restaurants", :force => true do |t|
    t.integer  "waiter_id"
    t.string   "name"
    t.string   "address"
    t.string   "food_type"
    t.binary   "logo_image"
    t.string   "logo_url"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
  end

end
