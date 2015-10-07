
class UserWorkoutsDone < Basemodel

	self.table_name = :user_workouts_done

	belongs_to :user, inverse_of: :workouts_done
	belongs_to :media, inverse_of: :usage_history


	validates :user_id, presence: true
	validates :media_id, presence: true


end