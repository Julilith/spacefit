class Feedback < Basemodel
	belongs_to :user

	validates :user_id, presence: true
	validates :text   , length: {minimum: 10, maximum: 5000}

end