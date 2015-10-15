class SignUpsController < ApplicationController


#---------------------------------- create
	def new
		@user=User.new
	end

	# Create users methods; usefull to redirect on different types of signup choises
	def new_with_redirect;
		@user=User.new;
		return redirect_to auth_path(:facebook) if params[:with]=="facebook"
		if !auth_hash.blank?
			if @user.facebook_info(auth_hash)=='mail missing'
				flash[:error]='Sign up failed, we need your email to sign you up'
				redirect_to root_path
			end
		end
	end

	#TODO You must give a provider!!!!!!!!
	def create 
		@user=User.new
		@user.provider="native"
		@user.assign_attributes(signup_params)
		@user.save!
		flash[:success]="Thanks for joining SPACEF!T, #{@user.name ||
																												@user.email.split("@").first }. "
		sign_in!(@user, true)
		redirect_to root_path
	rescue ActiveRecord::RecordInvalid,
					ActiveRecord::RecordNotUnique => e
		flash.now[:error]="We were not able to sign you up, please correct the following fields"
		@user.wipe
		render 'new'
	end

	def facebook
		_user=User.new;
		if _user.facebook_info(auth_hash)=='mail missing'
			flash[:error]='Sign up failed, we need your email to sign you up'
			redirect_to root_path
		elsif _euser=User.whos_email_is(_user.email)
			if _euser.provider=='facebook'
				#fix me we need to check the data and update the use again
				_euser.disclaimer==true ? sign_in!(_euser) : sign_in_temp!(_euser)
			elsif _euser.provider="linkedin"
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
			flash[:success]="Please read and check the disclaimer to fully access the application"
			_user.save!
			sign_in! _user
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

	def signup_params
			pa=params.require(:user).permit(:name,:email,:password,
																			:password_confirmation, :disclaimer)
			pa[:disclaimer].to_i==0 ? pa[:disclaimer]=false : pa[:disclaimer]=true 
			pa[:password_confirmation]=pa[:password]
			pa
	end

  def auth_hash
    request.env['omniauth.auth']
  end

end