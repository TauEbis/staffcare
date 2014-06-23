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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140623130554) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "locations", force: true do |t|
    t.string   "name"
    t.integer  "zone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mon_open",         default: 480, null: false
    t.integer  "mon_close",        default: 480, null: false
    t.integer  "tue_open",         default: 480, null: false
    t.integer  "tue_close",        default: 480, null: false
    t.integer  "wed_open",         default: 480, null: false
    t.integer  "wed_close",        default: 480, null: false
    t.integer  "thu_open",         default: 480, null: false
    t.integer  "thu_close",        default: 480, null: false
    t.integer  "fri_open",         default: 480, null: false
    t.integer  "fri_close",        default: 480, null: false
    t.integer  "sat_open",         default: 480, null: false
    t.integer  "sat_close",        default: 480, null: false
    t.integer  "sun_open",         default: 480, null: false
    t.integer  "sun_close",        default: 480, null: false
    t.integer  "rooms",            default: 1,   null: false
    t.integer  "max_mds",          default: 1,   null: false
    t.string   "report_server_id"
  end

  add_index "locations", ["zone_id"], name: "index_locations_on_zone_id", using: :btree

  create_table "memberships", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "zone_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree
  add_index "memberships", ["zone_id"], name: "index_memberships_on_zone_id", using: :btree

  create_table "schedules", force: true do |t|
    t.date     "starts_on"
    t.integer  "state",                                      default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "penalty_30min",      precision: 8, scale: 4,                 null: false
    t.decimal  "penalty_60min",      precision: 8, scale: 4,                 null: false
    t.decimal  "penalty_90min",      precision: 8, scale: 4,                 null: false
    t.decimal  "penalty_eod_unseen", precision: 8, scale: 4,                 null: false
    t.decimal  "penalty_slack",      precision: 8, scale: 4,                 null: false
    t.integer  "min_openers",                                                null: false
    t.integer  "min_closers",                                                null: false
    t.decimal  "md_rate",            precision: 8, scale: 4,                 null: false
    t.boolean  "oren_shift",                                 default: false, null: false
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "role"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "zones", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
