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

ActiveRecord::Schema.define(version: 20170213103159) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "locations", force: :cascade do |t|
    t.string   "lat"
    t.string   "lng"
    t.string   "icon"
    t.string   "name"
    t.string   "google_photo_reference"
    t.string   "cloudinary_link"
    t.string   "google_rating"
    t.string   "google_place_id"
    t.string   "vicinity"
    t.integer  "total_sockets"
    t.integer  "available_sockets"
    t.integer  "total_seats"
    t.integer  "available_seats"
    t.boolean  "coffee"
    t.boolean  "quiet"
    t.boolean  "wifi"
    t.string   "wifi_name"
    t.string   "wifi_password"
    t.boolean  "aircon"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "last_updated_user"
  end

  create_table "openingtimes", force: :cascade do |t|
    t.integer  "location_id"
    t.string   "day"
    t.time     "opening_time"
    t.time     "closing_time"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["location_id"], name: "index_openingtimes_on_location_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "locations", "users", column: "last_updated_user"
  add_foreign_key "openingtimes", "locations"
end
