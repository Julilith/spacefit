class SignUpsController < ApplicationController


#---------------------------------- create
	def new
	end

	# Create users methods; usefull to redirect on different types of signup choises
	def new_with_redirect;
		@user=User.new;
		return redirect_to auth_path(:facebook) if params[:with]=="facebook"
		return redirect_to auth_path(:linkedin) if params[:with]=="linkedin"
		if !auth_hash.blank?
			if @user.facebook_info(auth_hash)=='mail missing'
				flash[:error]='Sign up failed, we need your email to sign you up'
				redirect_to root_path
			end
		end
	end

	def create
		@user=User.new
		@user.assign_attributes(user_params)
		token=@user.process_token("confirm_email")
		@user.save!
		ManagementMailer.send("confirm_email", @user, token.value).deliver
		flash[:success]="Thanks for joining inlitera.com, #{@user.name ||
																												@user.email.split("@").first }. "<<
										 "To sign in confirm your account an follow the "<<
										 "instructions we just sent to #{@user.email}."
		redirect_to root_path
	rescue ActiveRecord::RecordInvalid,
					ActiveRecord::RecordNotUnique => e
					fail
		flash.now[:error]="We were not able to sign you up, please correct the following fields"
		@user.wipe
		render 'new'
	rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError,
				 Net::SMTPFatalError, Net::SMTPUnknownError => e
		in_developement {flash[:error] = "Email sending trouble: "+ e.message}
		try||=3; retry if (try-=1)<1
		user.wipe
		redirect_to root_path
	end


	def linkedin
		user=User.new;
		if user.linkedin_info(auth_hash)=='mail missing'
			flash[:error]='Sign up failed, we need your email to sign you up'
			redirect_to root_path
		elsif euser=User.whos_email_is(user.email).first
			if euser.provider=='linkedin'
				#fix me we need to check the data and update the use again
				sign_in! euser
			elsif euser.provider="facebook"
				flash[:error]="Your are already signed up with a Facebook account,
													sign in with LinkedIn
													"
			else
				flash[:error]="You are already signed up with us, request a
							 <a class='text_light'
									data-remote='true'
									href='/recover_password_new'
									data-actions=#{{remove: ".alert.alert-error"}.to_json}>
									new password</a>
							 if you have forgotten yours".html_safe
			end
			redirect_to root_path
		else
			user.save
			sign_in! user
			redirect_to edit_user_path(current_user)
		end
	end

	def facebook
		user=User.new;
		if user.facebook_info(auth_hash)=='mail missing'
			flash[:error]='Sign up failed, we need your email to sign you up'
			redirect_to root_path
		elsif euser_mail=UserEmail.where(email: user.email).load_joins(:user).first
			euser=euser_mail.user
			if euser.provider=='facebook'
				#fix me we need to check the data and update the use again
				sign_in! euser
			elsif euser.provider="linkedin"
				flash[:error]="Your are already signed up with a LinkedIn account,
													sign in with LinkedIn or change your account settings "
			else
				flash[:error]="You are already signed up with us, request a
							 <a class='text_light'
									data-remote='true'
									href='/recover_password_new'
									data-actions=#{{remove: ".alert.alert-error"}.to_json}>
									new password</a>
							 if you have forgotten yours".html_safe
			end
			redirect_to root_path
		else
			user.save
			sign_in! user
			redirect_to edit_user_path(current_user)
		end
	end

#---------------------------------- Email
	class OrphanToken  < StandardError; end
	class NoTokenFound < StandardError; end
	class InvalidToken < StandardError; end

	def confirm_email
		token=TemporaryToken.where(user_params).joins(:user).eager_load(user: :emails)[0]
		raise NoTokenFound if !token
		raise InvalidToken if !token.is_valid?("confirm_email")
		token.user.emails.confirm
		flash[:success]="You have finished your registration"
		sign_in! token.user
	rescue NoTokenFound
		flash[:error]="Sorry, the link isn't valid or too old, try again"
	rescue InvalidToken
		flash[:error]="Sorry, the link isn't valid or too old, try again"
		token.user.wipe if !token.user.emails.confirmed
	ensure
		token.try(:destroy)
		redirect_to root_path
	end

#———————————————————————————————————Private methods———————————————————————————————#
	private

	def user_avatar
		params[:user].try(:[],:avatar)
	end

	def user_params
		if action_name=="confirm_email"
			{token: params[:token], purpose: "confirm_email"}
		elsif action_name=="change_email"
			{token: Token.digest(params[:token]), purpose: "change_email"}
		else
			pa=params.require(:user).permit(:name,:email,:password,
																			:password_confirmation, :alias)
		end
	end

  def auth_hash
    request.env['omniauth.auth']
  end

end