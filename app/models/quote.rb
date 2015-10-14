class Quote <Basemodel
	#———————————————————————————————————Class data——————————————————————————————————#

	LANG=["en","fr"]
	#———————————————————————————————————Associations————————————————————————————————#

	has_many :given_to, class_name: "UserQuote",
										 dependent: :destroy,
										 inverse_of: :quote


	#———————————————————————————————————Validations—————————————————————————————————#
	validates :text,     presence: true
	validates :author,   presence: true
	validates :language,  inclusion: { in: LANG }

	#———————————————————————————————————Callbacks———————————————————————————————————#


	#———————————————————————————————————Scopes——————————————————————————————————————#
	scope :select_quote, ->(params_) {
		order("RANDOM()").limit(1)
	}

	scope :new_quote, ->(params_) {
		where().not(id: params_[:ids]).where(language: params_[:language] || "en").order("RANDOM()").limit(1)
	}



	#———————————————————————————————————Methods—————————————————————————————————————#

end
