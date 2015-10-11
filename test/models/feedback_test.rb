class FeedbackTest < ActiveSupport::TestCase

	def setup
		@nuser=User.new
		@nuser.provider="temp"
		@nuser.disclaimer=true
		@nuser.populate_temp_user
		@nuser.save!
	end

	test "valid_text" do
		_nfbk=Feedback.new
		_nfbk.user_id=12
		_nfbk.text= "a"* 12
		assert( _nfbk.save && !!(_nfbk.text== "a"* 12) && !!(_nfbk.user_id==12))


		# if text is too short it should fail
		_nfbk=Feedback.new
		_nfbk.user_id=12
		_nfbk.text= "a"* 9

		assert_raises  ActiveRecord::RecordInvalid do
			ActiveRecord::Base.transaction(requires_new: true) do 
				_nfbk.save!
			end
		end

		# if text is too short it should fail
		_nfbk=Feedback.new
		_nfbk.user_id=nil
		_nfbk.text= "a"* 8

		assert_raises  ActiveRecord::RecordInvalid do
			ActiveRecord::Base.transaction(requires_new: true) do 
				_nfbk.save!
			end
		end

	end


	test "relations" do
		_nfbk=Feedback.new
		_nfbk.user=@nuser
		_nfbk.text= "a"* 12
		_nfbk.save
		assert(_nfbk.user==@nuser)
	end


end