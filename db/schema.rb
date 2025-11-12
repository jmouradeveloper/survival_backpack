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

ActiveRecord::Schema[8.0].define(version: 2025_11_12_215633) do
  create_table "api_tokens", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "token_digest"
    t.string "name"
    t.datetime "last_used_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "food_items", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.decimal "quantity"
    t.date "expiration_date"
    t.string "storage_location"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.integer "days_before_expiration", default: 7, null: false
    t.boolean "enable_push_notifications", default: true, null: false
    t.boolean "enable_email_notifications", default: false, null: false
    t.datetime "last_checked_at"
    t.string "push_subscription_endpoint"
    t.text "push_subscription_keys"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "food_item_id", null: false
    t.string "title", null: false
    t.text "body"
    t.string "notification_type", default: "expiration_warning", null: false
    t.boolean "read", default: false, null: false
    t.datetime "sent_at"
    t.datetime "scheduled_for"
    t.integer "priority", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_item_id"], name: "index_notifications_on_food_item_id"
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["read"], name: "index_notifications_on_read"
    t.index ["scheduled_for"], name: "index_notifications_on_scheduled_for"
  end

  create_table "supply_batches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "food_item_id", null: false
    t.decimal "initial_quantity", precision: 10, scale: 2, null: false
    t.decimal "current_quantity", precision: 10, scale: 2, null: false
    t.date "entry_date", null: false
    t.date "expiration_date"
    t.text "batch_code"
    t.text "supplier"
    t.decimal "unit_cost", precision: 10, scale: 2
    t.text "notes"
    t.text "status", default: "active", null: false
  end

  create_table "supply_rotations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "supply_batch_id", null: false
    t.integer "food_item_id", null: false
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.date "rotation_date", null: false
    t.text "rotation_type", null: false
    t.text "reason"
    t.text "notes"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.integer "role"
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "api_tokens", "users"
  add_foreign_key "notifications", "food_items"
  add_foreign_key "supply_batches", "food_items"
  add_foreign_key "supply_rotations", "food_items"
  add_foreign_key "supply_rotations", "supply_batches"
end
