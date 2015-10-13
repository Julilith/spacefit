#———————————————————————————————————CurrentUser class—————————————————————————————#
#creates current user functionality helper
module CurrentUser

	class CurrentUser
		include Token
		require 'ipaddr'

		#remove unecessary methods
		instance_methods.each do |m| 
			undef_method m unless m =~ /(^__|^send$|^object_id$)/ || m=="puts"
		end

		def initialize(env, block=nil)
			@env=env
			@cookies_token=env.cookie_token
			@block=block
		end

		def set(user)
			@current=user
		end

		def is?(params)
			return false if current.id.nil?
			if params.kind_of?(Hash)
				from_params_is?(params)
			else
				from_record_is?(params)
			end
		end

		def current
			@current ||= try_model(@block)
		end

		def signed_in?
			current.id!=nil && current.provider!="temp"
		end

		def temp?
			current.id!=nil && current.provider=="temp"
		end

		def sign_out!
			current.sessions.to_a.map {|i| i.destroy if i.token==@cookies_token }
			@env.cookie_delete(:token)
			@current = dummy_user
		end

		private

		def method_missing(name, *args, &block)
			current.__send__(name, *args, &block)
		end

		def try_model(block=nil)
			return @current=dummy_user if @cookies_token.nil?

			@user_type   =  User
			@session_type= (@user_type.to_s+"Session").constantize
			_session=@session_type.where(token: @cookies_token)[0]
			if !_session.nil?
				_session = @session_type.where(token: @cookies_token)[0].if_valid
				if !_session.nil?
					_session.store_on(:user, block) 
					@current= _session.user
				else
					dummy_user
				end
			else
				dummy_user
			end
		rescue NoMethodError
			#TODO try differen users untill we get the right one!!!
			#if not default to User
		end

		def dummy_user
			_ip = Struct.new(:value).new(@env.request.remote_ip.to_i)
			@dummy_user = User.whos_email_is("#{_ip.value}@spacefit.net") || begin
				_tuser            = User.new
				_tuser.provider   = "temp"
				_tuser.disclaimer = false
				_tuser.populate_temp_user(_ip)
				_tuser.save(validate: false)
				_tuser
			end
		end

		def from_params_is?(params)
			hash=params.dup
			if hash.keys.include?(:class)
				return false if current.class.name!=hash[:class]
			end
			hash.inject(true){ |t,i| t && current[i[0]]==j[1]}
		end

		def from_record_is?(record)
			current.matches?(record)
		end
	end
end