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

ActiveRecord::Schema[8.0].define(version: 2025_11_08_020800) do
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

  add_foreign_key "notifications", "food_items"
end
