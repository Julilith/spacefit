class SessionsController < BaseController
	#before_action :not_signed_in_or_redirected, only:[:create]
	#before_action :signed_in, only: [:destroy]

	def new
		# this is necessary to make the user log back to his own page
		# in case he tried to access a access a forbidden page with
		# friendly forwarding 
		respond_to do |format|
			format.html 
			format.js 
		end
	end

	#FIXME what is this one for?
	##soft redirect....?
	def redirect
		render 'sessions/new'
	end

	#---------------------------------- sing in
	class AlreadySignedIn < StandardError; end
	class UserNotFound    < StandardError; end
	class UserNotVerified < StandardError; end

	def create
		user, current= possible_users({email: session_params[:email],
																	 token: cookie_token})
		raise UserNotFound    if user.nil?
		raise AlreadySignedIn if user.matches?(current) if current
		raise UserNotVerified if user.emails.confirmed==false
		if user.authenticate(session_params[:password])
			current_user.set(current).sing_out! if !current.nil?
			sign_in!(user, session_params[:remember_me])
			@success="Welcome back"
		else
			raise UserNotFound
		end
	rescue UserNotFound
		@error_message='Invalid email/password combination'
	rescue UserNotVerified
		@error_message = 'Your account hasnt been confirmet yet. Comfirm it to sign up!'
	rescue AlreadySignedIn
		@success=nil
	ensure
		reply( @error_message ? failure_reply(@error_message) :
														success_reply() )
	end

	#---------------------------------- sing out
	def destroy
		current_user.sign_out!
		@success="See you next time"
		reply(success_reply)
	end

private

	def session_params
		params.require(:user).permit(:email,:password,:remember_me).symbolize_keys()
	end

	def possible_users(args_)
		_email   = !args_[:email].nil? ? User.whos_email_is(args_[:email])   : nil
		_current = !args_[:token].nil? ? User.whos_session_is(args_[:token]) : nil
		[_email, _current]
	end



end