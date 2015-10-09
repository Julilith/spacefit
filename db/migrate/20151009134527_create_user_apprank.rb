class CreateUserApprank < ActiveRecord::Migration
	def change
		create_table :user_appranks do |t|
			t.integer :user_id
			t.integer :rank
		end
		add_index :user_appranks, :user_id, unique: true
	end
end
