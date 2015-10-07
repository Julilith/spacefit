
require 'test_helper'

class UserTest < ActiveSupport::TestCase
	include Token
	def setup
	end


	test "native_new_user" do 
		_nuser=User.new
		_nuser.password="asdf"
		_nuser.password_confirmation="asdf"
		_nuser.email="asdf@asdf.asdf"
		_nuser.provider="native"
		_nuser.disclaimer=true
		_nuser.save

		#check correct user was saved
		_nuser=User.first
		assert(_nuser.email=="asdf@asdf.asdf" &&
					 _nuser.provider=="native" &&
					 _nuser.disclaimer==true)

		# no duplicated emails
		_suser=User.new
		_suser.password="asdf"
		_suser.password_confirmation="asdf"
		_suser.email="asdf@asdf.asdf"
		_suser.provider="native"
		_suser.disclaimer=true
		assert_raises  ActiveRecord::RecordNotUnique do
				ActiveRecord::Base.transaction(requires_new: true) do 
					_suser.save!
				end
			end

		# dicalimer must be true
		_suser=User.new
		_suser.password="asdf"
		_suser.password_confirmation="asdf"
		_suser.email="asdf@asdf.asdf"
		_suser.provider="native"
		_suser.disclaimer=false
		assert_raises  ActiveRecord::RecordInvalid do
				ActiveRecord::Base.transaction(requires_new: true) do 
					_suser.save!
				end
			end
	end

	test "populate_temp_user" do
		_token=Token.new
		_tuser=User.new
		_tuser.provider="temp"
		_tuser.disclaimer=true
		_tuser.populate_temp_user(_token)
		_tuser.save!

		assert(_tuser.email=="#{_token.value.to_s}@spacefit.com".downcase)

		# if i dont give a token it should still work
		_tuser=User.new
		_tuser.provider="temp"
		_tuser.disclaimer=true
		_token=_tuser.populate_temp_user()
		_tuser.save!
		assert(_tuser.email=="#{_token.value.to_s}@spacefit.com".downcase)
	end


	test "relations" do
		@nuser=User.new
		@nuser.provider="temp"
		@nuser.disclaimer=true
		@nuser.populate_temp_user
		@nuser.save!
		assert(!!@nuser.workouts_done.new.user_id)

		@nuser.reload
		assert(!!@nuser.feedbacks.new.user_id)

	end

end




