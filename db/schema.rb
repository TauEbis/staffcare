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

ActiveRecord::Schema.define(version: 20141208090532) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "location_plan_id"
    t.integer  "grade_id"
    t.integer  "cause",            default: 0,  null: false
    t.text     "body"
    t.json     "metadata",         default: {}, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["grade_id"], name: "index_comments_on_grade_id", using: :btree
  add_index "comments", ["location_plan_id", "created_at"], name: "index_comments_on_location_plan_id_and_created_at", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "grades", force: true do |t|
    t.integer  "location_plan_id",              null: false
    t.integer  "source",           default: 0,  null: false
    t.json     "coverages",        default: {}, null: false
    t.json     "breakdowns",       default: {}, null: false
    t.json     "points",           default: {}, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "grades", ["user_id"], name: "index_grades_on_user_id", using: :btree

  create_table "heatmaps", force: true do |t|
    t.string   "name"
    t.text     "days"
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "heatmaps", ["uid"], name: "index_heatmaps_on_uid", using: :btree

  create_table "location_plans", force: true do |t|
    t.integer  "location_id",                                              null: false
    t.integer  "schedule_id",                                              null: false
    t.integer  "visit_projection_id",                                      null: false
    t.json     "visits"
    t.integer  "approval_state",                              default: 0,  null: false
    t.integer  "chosen_grade_id"
    t.integer  "max_mds"
    t.integer  "rooms"
    t.integer  "min_openers"
    t.integer  "min_closers"
    t.integer  "open_times",                                  default: [],              array: true
    t.integer  "close_times",                                 default: [],              array: true
    t.integer  "wiw_sync",                                    default: 0,  null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "optimizer_state",                             default: 0,  null: false
    t.string   "optimizer_job_id"
    t.decimal  "normal",              precision: 8, scale: 4, default: [], null: false, array: true
    t.decimal  "max",                 precision: 8, scale: 4, default: [], null: false, array: true
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.integer  "zone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sun_open",           default: 480,  null: false
    t.integer  "sun_close",          default: 1260, null: false
    t.integer  "mon_open",           default: 480,  null: false
    t.integer  "mon_close",          default: 1260, null: false
    t.integer  "tue_open",           default: 480,  null: false
    t.integer  "tue_close",          default: 1260, null: false
    t.integer  "wed_open",           default: 480,  null: false
    t.integer  "wed_close",          default: 1260, null: false
    t.integer  "thu_open",           default: 480,  null: false
    t.integer  "thu_close",          default: 1260, null: false
    t.integer  "fri_open",           default: 480,  null: false
    t.integer  "fri_close",          default: 1260, null: false
    t.integer  "sat_open",           default: 480,  null: false
    t.integer  "sat_close",          default: 1260, null: false
    t.integer  "rooms",              default: 1,    null: false
    t.integer  "max_mds",            default: 1,    null: false
    t.integer  "min_openers",        default: 1,    null: false
    t.integer  "min_closers",        default: 1,    null: false
    t.string   "report_server_id"
    t.integer  "wiw_id"
    t.string   "uid"
    t.integer  "managers",           default: 1,    null: false
    t.integer  "assistant_managers", default: 1,    null: false
  end

  add_index "locations", ["uid"], name: "index_locations_on_uid", using: :btree
  add_index "locations", ["zone_id"], name: "index_locations_on_zone_id", using: :btree

  create_table "memberships", force: true do |t|
    t.integer  "user_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id", null: false
  end

  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree

  create_table "pages", force: true do |t|
    t.string   "name"
    t.text     "body"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["slug"], name: "index_pages_on_slug", unique: true, using: :btree

  create_table "patient_volume_forecasts", force: true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.json     "volume_by_location", default: {}, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "positions", force: true do |t|
    t.string  "name"
    t.integer "wiw_id"
    t.integer "hourly_rate"
    t.string  "key"
  end

  add_index "positions", ["key"], name: "index_positions_on_key", using: :btree

  create_table "pushes", force: true do |t|
    t.integer  "location_plan_id"
    t.json     "theory",           default: {}, null: false
    t.json     "log",              default: {}, null: false
    t.integer  "state",            default: 0,  null: false
    t.string   "job_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pushes", ["location_plan_id"], name: "index_pushes_on_location_plan_id", using: :btree

  create_table "report_server_ingests", force: true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "locations"
    t.string   "heatmaps"
    t.string   "totals"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rules", force: true do |t|
    t.integer "name",               default: 0,  null: false
    t.integer "grade_id"
    t.integer "position_id"
    t.json    "shift_space_params", default: {}, null: false
    t.json    "step_params",        default: {}, null: false
  end

  add_index "rules", ["grade_id"], name: "index_rules_on_grade_id", using: :btree
  add_index "rules", ["position_id"], name: "index_rules_on_position_id", using: :btree

  create_table "schedules", force: true do |t|
    t.date     "starts_on"
    t.integer  "state",                                          default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "penalty_30min",          precision: 8, scale: 4,             null: false
    t.decimal  "penalty_60min",          precision: 8, scale: 4,             null: false
    t.decimal  "penalty_90min",          precision: 8, scale: 4,             null: false
    t.decimal  "penalty_eod_unseen",     precision: 8, scale: 4,             null: false
    t.decimal  "md_hourly",              precision: 8, scale: 4,             null: false
    t.integer  "optimizer_state",                                default: 0, null: false
    t.string   "optimizer_job_id"
    t.decimal  "penalty_turbo",          precision: 8, scale: 4,             null: false
    t.date     "manager_deadline"
    t.date     "rm_deadline"
    t.date     "sync_deadline"
    t.datetime "active_notices_sent_at"
  end

  create_table "shifts", force: true do |t|
    t.integer  "grade_id",    null: false
    t.datetime "starts_at",   null: false
    t.datetime "ends_at",     null: false
    t.integer  "wiw_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position_id"
  end

  add_index "shifts", ["grade_id", "position_id", "starts_at"], name: "index_shifts_on_grade_id_and_position_id_and_starts_at", using: :btree
  add_index "shifts", ["grade_id", "starts_at"], name: "index_shifts_on_grade_id_and_starts_at", using: :btree
  add_index "shifts", ["position_id"], name: "index_shifts_on_position_id", using: :btree
  add_index "shifts", ["wiw_id"], name: "index_shifts_on_wiw_id", using: :btree

  create_table "speeds", force: true do |t|
    t.integer  "doctors",                             null: false
    t.decimal  "normal",      precision: 5, scale: 2, null: false
    t.decimal  "max",         precision: 5, scale: 2, null: false
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "speeds", ["doctors", "location_id"], name: "index_speeds_on_doctors_and_location_id", unique: true, using: :btree
  add_index "speeds", ["location_id"], name: "index_speeds_on_location_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",                           null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,                            null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,                            null: false
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
    t.string   "time_zone",              default: "Eastern Time (US & Canada)"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "visit_projections", force: true do |t|
    t.integer  "schedule_id", null: false
    t.integer  "location_id", null: false
    t.string   "source"
    t.json     "heat_maps"
    t.json     "volumes"
    t.json     "visits"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zones", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
