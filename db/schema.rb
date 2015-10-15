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

ActiveRecord::Schema.define(version: 20151012081056) do

  create_table "feedbacks", force: :cascade do |t|
    t.integer "user_id"
    t.text    "text"
  end

  add_index "feedbacks", ["user_id"], name: "index_feedbacks_on_user_id"

  create_table "medias", force: :cascade do |t|
    t.string "wo_type"
    t.string "location"
    t.string "position"
    t.string "link"
  end

  add_index "medias", ["wo_type", "location", "position"], name: "index_medias_on_wo_type_and_location_and_position"

  create_table "quotes", force: :cascade do |t|
    t.string "text"
    t.string "author"
    t.string "language"
  end

  create_table "user_emails", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "email",      limit: 255,                 null: false
    t.boolean  "confirmed",              default: false, null: false
    t.datetime "created_at"
  end

  add_index "user_emails", ["email"], name: "index_user_emails_on_email", unique: true
  add_index "user_emails", ["user_id", "confirmed"], name: "index_user_emails_on_user_id_and_confirmed", unique: true

  create_table "user_likes_media", force: :cascade do |t|
    t.integer "user_id"
    t.integer "media_id"
  end

  add_index "user_likes_media", ["user_id", "media_id"], name: "index_user_likes_media_on_user_id_and_media_id", unique: true

  create_table "user_quotes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "quote_id"
  end

  add_index "user_quotes", ["user_id", "quote_id"], name: "index_user_quotes_on_user_id_and_quote_id"

  create_table "user_sessions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token",      limit: 255
    t.datetime "created_at"
  end

  add_index "user_sessions", ["created_at"], name: "index_user_sessions_on_created_at"
  add_index "user_sessions", ["token"], name: "index_user_sessions_on_token", unique: true
  add_index "user_sessions", ["user_id"], name: "index_user_sessions_on_user_id"

  create_table "user_workouts_done", force: :cascade do |t|
    t.string   "media_id"
    t.string   "user_id"
    t.datetime "created_at"
  end

  add_index "user_workouts_done", ["user_id"], name: "index_user_workouts_done_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "provider",        limit: 255
    t.string   "password_digest", limit: 255
    t.datetime "created_at"
    t.boolean  "disclaimer"
    t.integer  "rateapp"
    t.string   "language"
    t.boolean  "reminder",                    default: true
    t.integer  "every",                       default: 1
    t.integer  "from",                        default: 8
    t.integer  "to",                          default: 22
  end

end
