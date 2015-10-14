class UserWorkoutsDone < ActiveRecord::Migration
	def change
		create_table :user_workouts_done do |t|
			t.string   :media_id
			t.string   :user_id
			t.datetime  :created_at
		end
		add_index :user_workouts_done, [:user_id]
	end
end
