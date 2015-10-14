class CreateUserQuotes < ActiveRecord::Migration
	def change
		create_table :user_quotes do |t|
			t.integer :user_id
			t.integer :quote_id
		end
		add_index :user_quotes, [:user_id, :quote_id]
	end
end
