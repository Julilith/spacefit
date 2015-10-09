class FeedbacksController< ApplicationController

	def new
		@user=current_user
	end

	def create
		_user=User.where(feedback_params[:user_id])[0]
		_feedback=_user.feedbacks.new(text: feedback_params[:text])
		_feedback.save!
		@success="Thanks for writing"
	rescue ActiveRecord::RecordInvalid
	ensure
		reply(success_reply)
	end

private

	def feedback_params
		parama.require(:feedback).permit(:user_id, :text)
	end

end