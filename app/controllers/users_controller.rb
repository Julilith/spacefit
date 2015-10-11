class UsersController < BaseController


#---------------------------------- media
	def like_media
		current_user.liked_media.new(media_id: params[:liked_media].to_i).save!

	#rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
		redirect_to(:back)
	end

	def rateapp
		current_user.update_attributes(rateapp: params[:user][:rateapp].to_i)
	end
#---------------------------------- show
	def show
		
	end

	def apply_changes
	end





#---------------------------------- edit
	# Edit user methods
	def edit;
		#@user=current_user{ eager_load(:emails)}
		#@info=current_user.info
	end

	def update_password
		new_password     =params.require(:user).permit(:password,
																									 :password_confirmation)
		valid_password   =current_user.authenticate(params[:user][:current_password])
		updated          =false
		if valid_password
			updated=current_user.update(new_params)
		elsif current_user.emails.confirmed(true)[0].nil?
			updated=current_user.update(new_password)
		end
		@failure=!updated
		@failure ? reply(failure_reply) : reply(success_reply)
	end

	def update_email
		email         =params.require(:user).permit(:email)
		valid_password=current_user.authenticate(params[:user][:current_password])
		updated       =false
		if valid_password
			updated=TokensController.email(current_user, email)
		end
		@failure=!updated
		@failure ? reply(failure_reply) : reply(success_reply)
	end

#TODO add a method to validate your password if the provider is not native

	def update
		param=params.require(:user).permit(:name)
		current_user.update!(user_params)
		flash[:success]="Profile updated"
		redirect_to edit_user_path(@user)
		reply(success_reply)
	rescue ActiveRecord::RecordInvalid,
				 ActiveRecord::RecordNotUnique => e
		@fail=""
		reply(failure_reply)
	end

#---------------------------------- Recovers
	#Recover password
	def recover_password
		return if params[:user].nil?
		_params=params.require(:user).permit(:password,:password_confirmation,:token)
		_token=TemporaryToken.find_by_token(_params[:token])
		raise InvalidToken if !_token.try(:is_valid?, "reset_password")
		_user=_token.user
		raise OrphanToken  if _user.blank?
		_user.update(_params.except(:token))
		flash[:success]="You have updated your password"
		sign_in!(_user, true)
	rescue OrphanToken
		flash[:error]="Sorry we could not find you in our database"
	rescue InvalidToken
		flash[:error]="Sorry, the link is not valid or too old"
	ensure
		_token.try(:destroy)
		redirect_to root_path if !_params.blank?
	end

#---------------------------------- delete

	def change_email
		token=TemporaryToken.where(user_params).joins(:users).eager_load(users: :emails)[0]
		raise InvalidToken if !token.try(:is_valid?)
		#TODO neeed to log this error for debuging if it ever happens
		fail if !token.owner.emails.confirm
		flash[:success]="Great, you have successfully changed your email"
		redirect_to "/"
	rescue InvalidToken
		@failure=true
		flash[:error]="Sorry, the link isn't valid or too old, try again"
		user.wipe if !user.confirmed
	ensure
		token.try(:destroy)
		redirect_to root_path
	end

#---------------------------------- delete
	#destroy adapted to delete yourself interestig the user
	#self log-out once deleted. Even if no required explicitelly
	def destroy #TODO: SOFT DELETE
		user=User.find(params[:id])
		sign_out user
		user.wipe
		flash[:success]="By #{user.name} it was a pleasure to have meet you"
		redirect_to root_path
	end


#———————————————————————————————————Private methods———————————————————————————————#
	private



	def user_params
		if action_name=="recover_password"
			if !params[:user].blank?
				passwords=params.require(:user).permit(:password,:password_confirmation)
				{token: (params[:user][:token]),
				 reset_password: passwords.merge(new_password_requested: false)}
			end
		else
			pa=params.require(:user).permit(:name,:email,:password,
																			:password_confirmation, :alias)
			pa
		end
	end

end
