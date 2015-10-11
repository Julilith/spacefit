class User < Basemodel

	#———————————————————————————————————Class data——————————————————————————————————#
	#---------------------------------- User providers
	PROVIDER_TYPES=["facebook", "native", "temp"]

	#———————————————————————————————————Associations————————————————————————————————#


	#---------------------------------- emails
	has_many :emails, dependent:  :destroy  ,
										autosave:    true     ,
										inverse_of: :user     ,
										class_name: :UserEmail,
										inverse_of: :user

#	#---------------------------------- temporary tokens
#	has_many :tokens, ->{where(owner_type: "User")},
#										autosave:     true           ,
#										class_name:  :TemporaryToken ,
#										foreign_key: :owner_id       ,
#										dependent:   :destroy
	

	#---------------------------------- temporary tokens
	has_many :sessions, autosave:    true       ,
											class_name: :UserSession,
											dependent:  :destroy,
											inverse_of: :user

	#---------------------------------- feedbakcs
	has_many :feedbacks, dependent:  :destroy  ,
											 autosave:    true     ,
											 inverse_of: :user

	#---------------------------------- workouts
	has_many :workouts_done, dependent: :destroy,
													 class_name: :UserWorkoutsDone,
													 inverse_of: :user

	#---------------------------------- quotes
	has_many :quotes_given, dependent: :destroy,
													class_name: :UserQuote,
													inverse_of: :user

	#---------------------------------- apprank
	has_one :given_apprank, dependent:  :destroy,
													 class_name: :UserAppRank,
													 inverse_of: :user

	has_many :liked_media, dependent: :destroy,
												 class_name: :UserLikesMedia,
												 inverse_of: :user

	#———————————————————————————————————Scopes——————————————————————————————————————#

	#---------------------------------- adds secure passwor methods
	has_secure_password

	#---------------------------------- Get session token
	scope :active_session, ->(token="") {
		joins(:sessions).eager_load(:sessions).where(user_sessions: {token: token})
		}

	scope :temporary_tokens, ->(purpose="") {
		eager_load(:tokens).where(temporary_tokens: {purpose: purpose})
		}

	#———————————————————————————————————Validations—————————————————————————————————#
	validates :password, length: {minimum: 4, maximum: 25}, allow_nil: true
	validates :emails  , presence:   true
	validates :provider, inclusion: { in: PROVIDER_TYPES }
	validates :disclaimer, inclusion: { in: [true] }

	#———————————————————————————————————Callbacks———————————————————————————————————#

	# add random password for Linked in and Fb accounts
	before_validation ->{ if self.password.blank? && !(["native","temp"].include?(self.provider))
												lput "this is active"
													self.password=Token.new.value.to_s
													self.password_confirmation=self.password
												end}, on: :create

	#———————————————————————————————————Methods—————————————————————————————————————#

	def stay_connected
	end


	def populate_temp_user(token_=nil)
		_token=token_||Token.new
		self.password=_token.value.to_s
		self.password_confirmation=self.password
		self.email=("#{self.password.to_s}@spacefit.com")
		return _token
	end

	#----------------------------------unique email
	def email
		email_rec=self.emails
		if email_rec.count<2
			email_rec[0].try(:email)
		else
			email_rec.to_a.select {|x| x.confirmed==true}[0].try(:email)
		end
	end

	def email_unconfirmed
		self.emails.to_a.select {|x| x.confirmed==false}[0].try(:email)
	end

	# a new record of emails will be created when called
	def email=(email)
		self.emails.new(email: email)
	end

	#----------------------------------seeder

	def User.seeder(name)
		User.new(name: name,
						 email: name+"@"+name+"."+name,
						 password: name,
						 password_confirmation: name)
	end

	#---------------------------------- soft_delete
	#TODO
	def soft_delete
		#to be done
	end

	#---------------------------------- wipe
	#Deletes the user and removes the picture
	def wipe
		if self.destroy && !self.id.blank?
		end
	end


	#---------------------------------- facebook_info
	#build FIXME
	def facebook_info(auth_obj)
		info=auth_obj.extra.raw_info
		return 'mail missing' if info.email.blank?
		basics={}.setnb(sex:        gender_decoder(info.try(:gender)),
										birthday:    fb_time(info.try(:birthday)),
										first_name:  info.try(:first_name),
										middle_name: info.try(:middle_name),
										last_name:   info.try(:last_name))
		name=basics.slice(:first_name, :middle_name, :last_name).values.reject{ |c| c.blank? }.join(" ")
		self.attributes={provider:                auth_obj.provider,
										 email:                   info.email,
										 name:                    name,
										 info_attributes:         basics}
	end

	#———————————————————————————————————————————————————————————————————————————————#
	#————                     >>>>>>>>>temporary_tokens<<<<<<<<<                ————#
	#———————————————————————————————————————————————————————————————————————————————#

	#---------------------------------- create token and send mail
	def process_token(type)
		token=Token.new
		self.tokens.new(token, type)
		token
	end

	#———————————————————————————————————————————————————————————————————————————————#
	#————                     >>>>>>>>>emails<<<<<<<<<                         ————#
	#———————————————————————————————————————————————————————————————————————————————#

	#---------------------------------- with email
	def self.whos_email_is(email_)
		_email=UserEmail.where(email: email_).load_joins(:user)[0]
		_email.nil? ? nil : _email.user
	end

	#———————————————————————————————————————————————————————————————————————————————#
	#————                     >>>>>>>>>sessions<<<<<<<<<                        ————#
	#———————————————————————————————————————————————————————————————————————————————#


	def self.whos_session_is(token_)
		_session=UserSession.where(token: token_).load_joins(:user)[0]
		!_session.nil? && _session.is_valid? ? _session.user : nil
	end


	#———————————————————————————————————Private—————————————————————————————————————#
	private

	def gender_decoder(gender)
		hash={"male" => 1, "female" => 2}
		gen=gender.to_s
		if gender.is_i?
			hash[gender.to_i]
		else
			hash.to_a.transpose[0][gender.to_i]
		end
	end

	def fb_time(time)
		tim=time.to_s.split("/")
		Time.gm(tim[2],tim[0],tim[1]) if tim.length==3
		Time.gm(tim[1],tim[0])        if tim.length==2
		Time.gm(tim[0])               if tim.length==1 && time!=""
		nil                           if time==""
	end

end
