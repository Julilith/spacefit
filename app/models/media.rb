
class Media < Basemodel

	self.table_name = "medias"

	TYPES    =["fit", "relax", "stretch"]
	LOCATIONS=["home", "work", "travel"]
	POSITION =["stand", "sit"]
	#———————————————————————————————————Class data——————————————————————————————————#

	#———————————————————————————————————Associations————————————————————————————————#

	#---------------------------------- user_workouts_done
	has_many   :usage_history, class_name: :UserWorkoutsDone

	#———————————————————————————————————Scopes——————————————————————————————————————#
	#———————————————————————————————————Validations—————————————————————————————————#
	validates :type,     inclusion: { in: TYPES }
	validates :location, inclusion: { in: LOCATIONS }
	validates :position, inclusion: { in: POSITION }
	validates :link,     presence: true

	#———————————————————————————————————Callbacks———————————————————————————————————#
	#———————————————————————————————————Methods—————————————————————————————————————#

	def type=(name_)
		self.wo_type=name_
	end

	def type
		self.wo_type
	end

end