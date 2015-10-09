class UserLikesMedia < Basemodel


	#———————————————————————————————————Class data——————————————————————————————————#
	self.table_name="user_likes_media"
	#———————————————————————————————————Associations————————————————————————————————#

	#---------------------------------- user
	belongs_to :user, inverse_of: :liked_media


	#———————————————————————————————————Validations—————————————————————————————————#
	validates :user_id,  presence: true
	validates :media_id, presence: true
	#———————————————————————————————————Callbacks———————————————————————————————————#


	#———————————————————————————————————Scopes——————————————————————————————————————#

	#———————————————————————————————————Methods—————————————————————————————————————#
end