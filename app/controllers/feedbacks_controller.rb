class FeedbacksController< BaseController

	def new
	end

	def create
		current_user.feedbacks.new(text: feedback_params[:text]).save!
		@success="Thanks for writing"
	rescue ActiveRecord::RecordInvalid
	ensure
		reply(success_reply @success)
	end

private

	def feedback_params
		params.require(:feedback).permit(:user_id, :text)
	end

end