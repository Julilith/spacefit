module SessionsHelper
	include CurrentUser
	include Token

	#def create
	#	render 'new'
	#end

	def current_user(&block)
		@current_user ||= CurrentUser.new(self, block)
	end

	def cookie_token
		Token.digest(cookies[:token]) if !cookies[:token].nil?
	end

	def cookie_delete(args)
		cookies.delete(args)
	end


	#---------------------------------- Sing in and out methods
	#to destroy a session permanently you have to use session, you cannot force
	#a cookie to dissappear from the browser. A permanent log in should use cookies
	#while a temporary log in should use the session cookie jar
	def sign_in!(user, remember_me=false)
		cookie_type    =remember_me ? 1.month.from_now : nil 
		token          =user.sessions.new
		#.signed
		cookies[:token]={value: token.value, expires: cookie_type}.no_blank
		user.save!
		current_user.set(user)
	end

	def signed_in_user
		if !current_user.signed_in?
			store_location
			redirect_to signin_path, notice: "Please sign in."
		end
	end


	def redirect_back_or(default)
		redirect_to(session[:return_to]||default)
		session.delete(:return_to)
	end

	def store_location
		session[:return_to]=request.url if request.get?
	end

end
