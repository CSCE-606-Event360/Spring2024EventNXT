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

ActiveRecord::Schema[7.0].define(version: 2023_05_05_045543) do
  create_table "email_services", force: :cascade do |t|
    t.string "to"
    t.string "subject"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "sent_at"
    t.datetime "committed_at"
    t.integer "event_id"
    t.integer "guest_id"
    t.index ["event_id"], name: "index_email_services_on_event_id"
    t.index ["guest_id"], name: "index_email_services_on_guest_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.string "address"
    t.string "description"
    t.datetime "datetime"
    t.datetime "last_modified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "event_avatar"
    t.string "event_box_office"
  end

  create_table "guests", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "affiliation"
    t.string "category"
    t.integer "alloted_seats"
    t.integer "commited_seats"
    t.integer "guest_commited"
    t.boolean "status"
    t.integer "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_guests_on_event_id"
  end

  create_table "seats", force: :cascade do |t|
    t.string "category"
    t.integer "total_count"
    t.integer "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_seats_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "email_services", "events"
  add_foreign_key "email_services", "guests"
  add_foreign_key "guests", "events"
  add_foreign_key "seats", "events"
end
