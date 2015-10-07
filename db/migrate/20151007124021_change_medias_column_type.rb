class ChangeMediasColumnType < ActiveRecord::Migration
	def change
		change_column :user_workouts_done, :user_id, :integer
		change_column :user_workouts_done, :media_id, :integer
	end
end
