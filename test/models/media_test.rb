class MediaTest < ActiveSupport::TestCase

	def setup
		@media=Media.new
		@media.type=Media::TYPE[rand(Media::TYPE.length)]
		@media.location=Media::LOCATION[rand(Media::LOCATION.length)]
		@media.position=Media::POSITION[rand(Media::POSITION.length)]
		@media.link="somelink"
		@media.save!

	end

	test "test_validations" do
		_media=Media.new
		_media.type=Media::TYPE[rand(Media::TYPE.length)]
		_media.location=Media::LOCATION[rand(Media::LOCATION.length)]
		_media.position=Media::POSITION[rand(Media::POSITION.length)]
		_media.link="somelink"
		_media.save!
		assert(!!_media.type && !!_media.location && !! _media.position)

		_media=Media.new
		_media.type="sdf"
		_media.location="lkjasdf"
		_media.position="lkjhasdf"
		_media.link="somelink2"
			assert_raises  ActiveRecord::RecordInvalid do
				ActiveRecord::Base.transaction(requires_new: true) do 
					_media.save!
				end
			end

	end

	test "relations" do
		assert(@media.usage_history.new.media_id==@media.id)
	end 

end