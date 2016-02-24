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

ActiveRecord::Schema.define(version: 20160221132354) do

  create_table "employees", force: :cascade do |t|
    t.string   "first_name"
    t.string   "second_name"
    t.string   "title"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "employees_events", id: false, force: :cascade do |t|
    t.integer "event_id"
    t.integer "employee_id"
  end

  add_index "employees_events", ["employee_id"], name: "index_employees_events_on_employee_id"
  add_index "employees_events", ["event_id"], name: "index_employees_events_on_event_id"

  create_table "event_services", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "event_services", ["event_id"], name: "index_event_services_on_event_id"
  add_index "event_services", ["service_id"], name: "index_event_services_on_service_id"

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "client_name"
    t.string   "phone_number"
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "workshop_id"
  end

  add_index "events", ["workshop_id"], name: "index_events_on_workshop_id"

  create_table "services", force: :cascade do |t|
    t.string   "name"
    t.decimal  "cost"
    t.decimal  "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username",               default: "", null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "role"
    t.integer  "workshop_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["workshop_id"], name: "index_users_on_workshop_id"

  create_table "workshops", force: :cascade do |t|
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
