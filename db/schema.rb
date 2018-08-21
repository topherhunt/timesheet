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

ActiveRecord::Schema.define(version: 20180820220709) do

  create_table "invoices", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "client_id",        limit: 4
    t.integer  "project_id",       limit: 4
    t.date     "date_start"
    t.date     "date_end"
    t.decimal  "total_hours",                precision: 6, scale: 2
    t.integer  "total_bill_cents", limit: 4
    t.boolean  "is_sent",                                            default: false
    t.boolean  "is_paid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   limit: 4, null: false
    t.integer "descendant_id", limit: 4, null: false
    t.integer "generations",   limit: 4, null: false
  end

  add_index "project_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "project_anc_desc_idx", unique: true, using: :btree
  add_index "project_hierarchies", ["descendant_id"], name: "project_desc_idx", using: :btree

  create_table "projects", force: :cascade do |t|
    t.integer  "user_id",                limit: 4
    t.integer  "parent_id",              limit: 4
    t.string   "name",                   limit: 255
    t.boolean  "active",                                                     default: true
    t.integer  "rate_cents",             limit: 4,                           default: 0
    t.integer  "requires_daily_billing", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "weekly_target",                      precision: 6, scale: 2
    t.date     "start_date"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",                 null: false
    t.string   "encrypted_password",     limit: 255, default: "",                 null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,                  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone",              limit: 255, default: "America/New_York"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "work_entries", force: :cascade do |t|
    t.integer  "user_id",              limit: 4
    t.integer  "project_id",           limit: 4
    t.decimal  "duration",                           precision: 4, scale: 2
    t.integer  "invoice_id",           limit: 4
    t.text     "invoice_notes",        limit: 65535
    t.text     "admin_notes",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.boolean  "exclude_from_invoice",                                       default: false
    t.boolean  "creates_value",                                              default: false
  end

end
