class WorkoutsController< ApplicationController

	def type
	end

	def location
	end

	def position
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

private
	def workout_params
		@workout_params||= begin
		_wparams=params.permit(:type, :location, :position, :id)
		_wparams[:id]=params[:id].split(",").map(&:to_i) if !params[:id].blank?
		_wparams.no_blank
		end
	end

end