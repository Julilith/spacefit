class UserQuote < Basemodel
	#———————————————————————————————————Class data——————————————————————————————————#
	self.table_name= "user_quotes"
	#———————————————————————————————————Associations————————————————————————————————#

	#---------------------------------- user
	belongs_to :user, inverse_of: :quotes_given

	#---------------------------------- quote
	belongs_to :quote, inverse_of: :given_to

	#———————————————————————————————————Validations—————————————————————————————————#
	validates :text,     presence: true
	validates :author,   presence: true
	validates :lang,  inclusion: { in: LANG }

	#———————————————————————————————————Callbacks———————————————————————————————————#


	#———————————————————————————————————Scopes——————————————————————————————————————#
	scope :select_quote, ->(params_) {
		order("RANDOM()").limit(1)
	}

	#———————————————————————————————————Methods—————————————————————————————————————#
end