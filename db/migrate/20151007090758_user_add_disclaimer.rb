class UserAddDisclaimer < ActiveRecord::Migration
	def change
		add_column :users, :disclaimer, :boolean, defaults: false
	end
end
