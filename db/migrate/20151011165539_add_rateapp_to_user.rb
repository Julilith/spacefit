class AddRateappToUser < ActiveRecord::Migration
	def change
		add_column :users, :rateapp, :integer
	end
end
