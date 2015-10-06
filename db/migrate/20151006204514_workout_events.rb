class UserWorkoutEvents < ActiveRecord::Migration
	def change
		create_table :user_workout_events do |t|
			t.string   :media_id
			t.string   :user_id
			t.datetime  :created_at
		end
		add_index :user_workout_events, [:user_id]
	end
end
