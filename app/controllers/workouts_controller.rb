class WorkoutsController< ApplicationController

	def type
	end

	def location
	end

	def position
	end

	def reload
		@media=Media.where(id: params[:reload_id])[0]
		current_user.workouts_done.new(media_id: @media.id).save!
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
	ensure
		render "show"
	end


	def show
		if workout_params[:id].blank?
			@media=Media.select_video(workout_params)[0]
		elsif !workout_params[:id].blank? && workout_params[:id].count<Media::MAX
			@media=Media.select_video(workout_params)[0]
		else
			params[:id]=""
			@media=Media.select_video(workout_params)[0]
		end
		@media||=Media.new

	end

	def completed
		current_user.workouts_done.new(media_id: params[:id]).save!
		_old_quotes=current_user.quotes_given.pluck(:id)
		@quote=Quote.where.not(id: _old_quotes).limit(1)[0]
		current_user.quotes_given.create(quote_id: @quote.id)

		
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