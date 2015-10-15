module SessionsHelper
	include Token


	def current_user(&block)
		@current_user ||= CurrentUserHelper::CurrentUser.new(self, block)
	end

	def cookie_token
		Token.digest(cookies[:token]) if !cookies[:token].nil?
	end

	def cookie_delete(args)
		cookies.delete(args)

	end

	def sign_in_temp!(user_, token_=Token.new)
		_session        = UserSession.new(token: token_.digest, user_id: user_.id)
		cookies[:token] = {value: token_.value}
		_session.save!(validate: false)
		user_
	end

	#---------------------------------- Sing in and out methods
	#to destroy a session permanently you have to use session, you cannot force
	#a cookie to dissappear from the browser. A permanent log in should use cookies
	#while a temporary log in should use the session cookie jar
	def sign_in!(user_, remember_me_=false, token_=Token.new)
		_cookie_type = remember_me_ ? 1.month.from_now : nil 
		_token       = user_.sessions.new(token_)
		cookies[:token] = {value: _token.value, expires: 1.month.from_now}.no_blank
		user_.save!
		current_user.set(user_)
		return current_user
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

private


end
