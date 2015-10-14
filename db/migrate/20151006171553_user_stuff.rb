class UserStuff < ActiveRecord::Migration
	def change

		create_table "users" do |t|
			t.string   "name",            limit: 255
			t.string   "provider",        limit: 255
			t.string   "password_digest", limit: 255
			t.datetime "created_at"
		end

		create_table "user_emails", force: :cascade do |t|
			t.integer  "user_id"
			t.string   "email",      limit: 255,                 null: false
			t.boolean  "confirmed",              default: false, null: false
			t.datetime "created_at"
		end

		add_index "user_emails", ["email"], unique: true
		add_index "user_emails", ["user_id", "confirmed"], unique: true

		create_table "user_sessions" do |t|
			t.integer  "user_id"
			t.string   "token",      limit: 255
			t.datetime "created_at"
		end

		add_index "user_sessions", ["created_at"]
		add_index "user_sessions", ["token"],      unique: true
		add_index "user_sessions", ["user_id"]


	end
end
