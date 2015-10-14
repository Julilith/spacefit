class UserWorkoutsDoneTest < ActiveSupport::TestCase

	def setup
		@nuser=User.new
		@nuser.password="asdf"
		@nuser.password_confirmation="asdf"
		@nuser.email="asdf@asdf.asdf"
		@nuser.provider="native"
		@nuser.disclaimer=true
		@nuser.save



		@media=Media.new
		@media.type=Media::TYPE[rand(Media::TYPE.length)]
		@media.location=Media::LOCATION[rand(Media::LOCATION.length)]
		@media.position=Media::POSITION[rand(Media::POSITION.length)]
		@media.link="somelink"
		@media.save!
	end

	test "check_relations" do
		_wd=UserWorkoutsDone.new
		_wd.attributes={user: @nuser, media: @media}
		_wd.save!
		assert(!User.first.workouts_done.blank? &&  !Media.first.usage_history.blank?)
	end

end