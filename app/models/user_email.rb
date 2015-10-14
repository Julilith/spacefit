class UserEmail < Basemodel
	
	#add_index :user_emails, :email                , unique: true
	#add_index :user_emails, [:user_id, :confirmed], unique: true
	
	#———————————————————————————————————Associations————————————————————————————————#
	#---------------------------------- user
	belongs_to :user, inverse_of: :emails

	#———————————————————————————————————Scopes——————————————————————————————————————#
	scope :confirmed, ->(confirmed=true){where(confirmed: confirmed)}

	#———————————————————————————————————Callbacks———————————————————————————————————#
	before_save       ->{self.email.downcase!}
	before_validation ->{self.confirmed=true if self.user.provider!="native"}, on: :create


	#———————————————————————————————————Validations—————————————————————————————————#
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence:   true,
										length:     {maximum: 50},
										format:     {with: VALID_EMAIL_REGEX}

	#———————————————————————————————————Methods—————————————————————————————————————#
	#---------------------------------- user
	class ActiveRecord_Associations_CollectionProxy
		class TooManyEmails < StandardError; end

		def confirm
			email_number=@association.length
			if    email_number==0
				puts "no emails found"
				false
			elsif email_number==1
				confirm_new
			elsif email_number==2
				confirm_change
			end

			def confirmed(conf=true)
				where(confirmed: true)[0]
			end
		end

	private

		def clean_up
			mails=self.to_a
			self.to_a.map{ |x| x.delete if x.confirmed==false}
			false
		end

		def confirm_new
			self[0].update!(confirmed: true)
		end

		def confirm_change
			mail_con  =self.select{|x| x.confirmed==true }[0]
			mail_uncon=self.select{|x| x.confirmed==false}[0]
			ActiveRecord::Base.transaction do
				mail_con.delete
				mail_uncon.update!(confirmed: true)
			end
			true
		rescue 
			false
		end

	end

end