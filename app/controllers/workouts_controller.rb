#
#
# ATTENTION GIVEN THE LACK OF MEDIA RELOAD AND SHOW METHODS ARE BADLY UN COMMENTED
#
#

class WorkoutsController< BaseController

	before_action :require_disclaimer

	def type
	end

	def location
	end

	def position
	end

	def reload
		#@media=Media.where(id: params[:reload_id])[0]
		@media = Media.select_video( workout_params.slice(:type, :position, :location) )[0] || Media.first

		#current_user.workouts_done.new(media_id: @media.id).save!
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
	ensure
		render "show"
	end


	def show
#		if workout_params[:id].blank?
#			@media=Media.select_video(workout_params)[0]
#		elsif !workout_params[:id].blank? && workout_params[:id].count<Media::MAX
#			@media=Media.select_video(workout_params)[0]
#		else
#			params[:id]=""
#			@media=Media.select_video(workout_params)[0]
#		end
#		@media||=Media.new.first
		@media = Media.select_video( workout_params.slice(:type, :position, :location) )[0] || Media.first
	end

	def completed
		current_user.workouts_done.new(media_id: params[:id]).save!
		_old_quotes=current_user.quotes_given.pluck(:id)
		@quote=Quote.new_quote({language: I18n.locale ,id: _old_quotes})[0]
		current_user.quotes_given.create(quote_id: @quote.id)
		render template: "users/progress"
	end

private
	def workout_params
		@workout_params||= begin
		_wparams=params.permit(:type, :location, :position, :id)
		_wparams[:id]=params[:id].split(",").map(&:to_i) if !params[:id].blank?
		_wparams.no_blank
		end
	end

end