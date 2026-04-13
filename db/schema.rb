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

ActiveRecord::Schema[8.1].define(version: 2026_04_13_092500) do
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

  create_table "approval_steps", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "actor_id", null: false
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.string "from_status", null: false
    t.text "reason"
    t.string "to_status", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_approval_steps_on_actor_id"
    t.index ["booking_id", "created_at"], name: "index_approval_steps_on_booking_id_and_created_at"
    t.index ["booking_id"], name: "index_approval_steps_on_booking_id"
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

  create_table "password_reset_codes", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "code_digest", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.datetime "last_sent_at", null: false
    t.integer "resend_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.index ["email"], name: "index_password_reset_codes_on_email", unique: true
    t.index ["expires_at"], name: "index_password_reset_codes_on_expires_at"
    t.check_constraint "attempt_count >= 0", name: "password_reset_codes_attempt_count_non_negative"
    t.check_constraint "resend_count >= 0", name: "password_reset_codes_resend_count_non_negative"
  end

  create_table "signup_verification_codes", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "code_digest", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.datetime "last_sent_at", null: false
    t.integer "resend_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.index ["email"], name: "index_signup_verification_codes_on_email", unique: true
    t.index ["expires_at"], name: "index_signup_verification_codes_on_expires_at"
    t.check_constraint "attempt_count >= 0", name: "signup_verification_codes_attempt_count_non_negative"
    t.check_constraint "resend_count >= 0", name: "signup_verification_codes_resend_count_non_negative"
  end

  create_table "societies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tenants", force: :cascade do |t|
    t.integer "approval_mode", default: 0, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_tenants_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "active_session_token"
    t.string "college_scope_slug"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.boolean "is_root_account", default: false, null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.bigint "society_id"
    t.bigint "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["active_session_token"], name: "index_users_on_active_session_token", unique: true
    t.index ["college_scope_slug"], name: "index_users_on_college_scope_slug"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["society_id"], name: "index_users_on_society_id"
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  create_table "venue_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.text "rejection_reason"
    t.bigint "requester_id", null: false
    t.datetime "reviewed_at"
    t.bigint "reviewed_by_id"
    t.integer "status", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.string "venue_name", null: false
    t.index ["requester_id"], name: "index_venue_requests_on_requester_id"
    t.index ["reviewed_by_id"], name: "index_venue_requests_on_reviewed_by_id"
    t.index ["tenant_id"], name: "index_venue_requests_on_tenant_id"
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
  add_foreign_key "approval_steps", "bookings"
  add_foreign_key "approval_steps", "users", column: "actor_id"
  add_foreign_key "bookings", "equipment"
  add_foreign_key "bookings", "users"
  add_foreign_key "bookings", "venues"
  add_foreign_key "equipment", "tenants"
  add_foreign_key "users", "societies"
  add_foreign_key "users", "tenants"
  add_foreign_key "venue_requests", "tenants"
  add_foreign_key "venue_requests", "users", column: "requester_id"
  add_foreign_key "venue_requests", "users", column: "reviewed_by_id"
  add_foreign_key "venues", "tenants"
end
