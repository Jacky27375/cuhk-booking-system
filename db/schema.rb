# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_06_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.datetime "last_used_at"
    t.string "name", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["token"], name: "index_api_keys_on_token", unique: true
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date"
    t.datetime "end_time"
    t.bigint "equipment_id"
    t.integer "quantity", default: 0
    t.text "rejection_reason"
    t.date "start_date"
    t.datetime "start_time"
    t.integer "status", default: 0, null: false
    t.string "type"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "venue_id"
    t.index ["equipment_id"], name: "index_bookings_on_equipment_id"
    t.index ["type"], name: "index_bookings_on_type"
    t.index ["user_id"], name: "index_bookings_on_user_id"
    t.index ["venue_id"], name: "index_bookings_on_venue_id"
  end

  create_table "equipment", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "quantity", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_equipment_on_tenant_id"
  end

  create_table "societies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tenants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_tenants_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.integer "society_id"
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["society_id"], name: "index_users_on_society_id"
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  create_table "venues", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "department"
    t.text "description"
    t.string "name"
    t.bigint "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_venues_on_tenant_id"
  end

  add_foreign_key "api_keys", "users"
  add_foreign_key "bookings", "equipment"
  add_foreign_key "bookings", "users"
  add_foreign_key "bookings", "venues"
  add_foreign_key "equipment", "tenants"
  add_foreign_key "users", "societies"
  add_foreign_key "users", "tenants"
  add_foreign_key "venues", "tenants"
end
