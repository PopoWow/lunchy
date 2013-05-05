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

ActiveRecord::Schema.define(:version => 20130504072325) do

  create_table "courses", :force => true do |t|
    t.integer  "waiter_id"
    t.string   "description"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "name"
    t.integer  "restaurant_id"
    t.integer  "position"
    t.date     "date_for"
    t.boolean  "active",        :default => true
    t.float    "average_price"
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

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "dishes", :force => true do |t|
    t.integer  "waiter_id"
    t.string   "name"
    t.string   "description"
    t.float    "price"
    t.integer  "course_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "position"
    t.date     "date_for"
    t.boolean  "active",      :default => true
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

  create_table "users", :force => true do |t|
    t.string   "email",                                              :null => false
    t.string   "crypted_password"
    t.string   "salt"
    t.string   "nickname"
    t.boolean  "admin",                           :default => false
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "activation_state"
    t.string   "activation_token"
    t.datetime "activation_token_expires_at"
  end

  add_index "users", ["activation_token"], :name => "index_users_on_activation_token"
  add_index "users", ["remember_me_token"], :name => "index_users_on_remember_me_token"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token"

end
