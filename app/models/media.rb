
class Media < Basemodel

	self.table_name = "medias"

	TYPE    =["fit", "relax", "stretch", "unknown"]
	LOCATION=["home", "office", "travel", "unknown"]
	POSITION =["up", "sit", "unknown"]
	MAX=2
	#———————————————————————————————————Class data——————————————————————————————————#

	#———————————————————————————————————Associations————————————————————————————————#

	#---------------------------------- user_workouts_done
	has_many   :usage_history, class_name: :UserWorkoutsDone

	#———————————————————————————————————Validations—————————————————————————————————#
	validates :type,     inclusion: { in: TYPE }
	validates :location, inclusion: { in: LOCATION }
	validates :position, inclusion: { in: POSITION }
	validates :link,     presence: true

	#———————————————————————————————————Callbacks———————————————————————————————————#

	#———————————————————————————————————Scopes——————————————————————————————————————#
	scope :select_video, ->(params_) {
		where.
		not(id: params_[:id]).order("RANDOM()").
		where({wo_type: params_[:type], location: params_[:location], position: params_[:position]}.no_blank)
		.limit(1)
	}

	#———————————————————————————————————Methods—————————————————————————————————————#

	def type=(name_)
		self.wo_type=name_
	end

	def type
		self.wo_type
	end

end