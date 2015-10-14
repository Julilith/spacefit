class CreateUserLikesMedia < ActiveRecord::Migration
	def change
		create_table :user_likes_media do |t|
			t.integer :user_id
			t.integer :media_id
		end
		add_index :user_likes_media, [:user_id,:media_id], unique: true
	end
end
