class UserQuote < Basemodel
	#———————————————————————————————————Class data——————————————————————————————————#
	self.table_name= "user_quotes"
	#———————————————————————————————————Associations————————————————————————————————#

	#---------------------------------- user
	belongs_to :user, inverse_of: :quotes_given

	#---------------------------------- quote
	belongs_to :quote, inverse_of: :given_to

	#———————————————————————————————————Validations—————————————————————————————————#
	validates :quote_id, presence: true
	validates :user_id, presence: true
	#———————————————————————————————————Callbacks———————————————————————————————————#


	#———————————————————————————————————Scopes——————————————————————————————————————#
	scope :select_quote, ->(params_) {
		order("RANDOM()").limit(1)
	}

	#———————————————————————————————————Methods—————————————————————————————————————#
end