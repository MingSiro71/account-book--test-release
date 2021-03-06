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

ActiveRecord::Schema.define(version: 2019_07_15_034309) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "back_records", force: :cascade do |t|
    t.bigint "record_id"
    t.string "debit"
    t.string "credit"
    t.integer "amount"
    t.date "when"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "division_id"
    t.integer "tax"
    t.index ["division_id"], name: "index_back_records_on_division_id"
    t.index ["record_id"], name: "index_back_records_on_record_id"
  end

  create_table "divisions", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "disabled"
    t.index ["user_id"], name: "index_divisions_on_user_id"
  end

  create_table "records", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "division_id"
    t.integer "amount"
    t.date "when"
    t.string "where"
    t.string "where_from"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id"
    t.datetime "disabled"
    t.string "option"
    t.integer "tax"
    t.index ["division_id"], name: "index_records_on_division_id"
    t.index ["user_id"], name: "index_records_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "back_records", "divisions"
  add_foreign_key "divisions", "users"
  add_foreign_key "records", "divisions"
  add_foreign_key "records", "users"
end
