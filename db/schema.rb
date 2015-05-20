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

ActiveRecord::Schema.define(version: 20150520131652) do

  create_table "clients", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "name",       limit: 255
    t.integer  "rate_cents", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.integer  "client_id",   limit: 4
    t.integer  "rate_cents",  limit: 4
    t.date     "date_start"
    t.date     "date_end"
    t.decimal  "total_hours",           precision: 4, scale: 2
    t.boolean  "is_sent",     limit: 1,                         default: false
    t.boolean  "is_paid",     limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "client_id",  limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "work_entries", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "project_id",    limit: 4
    t.date     "date"
    t.decimal  "duration",                    precision: 4, scale: 2
    t.boolean  "will_bill",     limit: 1,                             default: true
    t.boolean  "is_billed",     limit: 1,                             default: false
    t.integer  "invoice_id",    limit: 4
    t.text     "invoice_notes", limit: 65535
    t.text     "admin_notes",   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
