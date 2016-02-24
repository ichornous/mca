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

ActiveRecord::Schema.define(version: 20151230154932) do

  create_table "cars", force: :cascade do |t|
    t.integer "workshop_id"
    t.string  "description"
    t.string  "license_id"
    t.string  "photo"
  end

  add_index "cars", ["workshop_id"], name: "index_cars_on_workshop_id"

  create_table "clients", force: :cascade do |t|
    t.integer  "workshop_id"
    t.string   "name"
    t.string   "phone"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "clients", ["workshop_id"], name: "index_clients_on_workshop_id"

  create_table "order_services", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "service_id"
    t.decimal  "amount"
    t.decimal  "cost"
    t.decimal  "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "order_services", ["order_id"], name: "index_order_services_on_order_id"
  add_index "order_services", ["service_id"], name: "index_order_services_on_service_id"

  create_table "orders", force: :cascade do |t|
    t.integer  "workshop_id"
    t.integer  "client_id"
    t.integer  "car_id"
    t.string   "state"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "orders", ["car_id"], name: "index_orders_on_car_id"
  add_index "orders", ["client_id"], name: "index_orders_on_client_id"
  add_index "orders", ["workshop_id"], name: "index_orders_on_workshop_id"

  create_table "services", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.decimal  "base_cost"
    t.decimal  "base_time"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer  "workshop_id"
    t.integer  "impersonation_id"
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
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["impersonation_id"], name: "index_users_on_impersonation_id"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["workshop_id"], name: "index_users_on_workshop_id"

  create_table "visits", force: :cascade do |t|
    t.integer  "workshop_id"
    t.integer  "order_id"
    t.boolean  "returning"
    t.text     "description"
    t.string   "client_name"
    t.string   "car_name"
    t.string   "phone_number"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "color"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "visits", ["order_id"], name: "index_visits_on_order_id"
  add_index "visits", ["workshop_id"], name: "index_visits_on_workshop_id"

  create_table "workshops", force: :cascade do |t|
    t.string   "description"
    t.string   "color"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
