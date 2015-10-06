class FeedbacksController< ApplicationController
	include MyMethods
	include Permissions

#———————————————————————————————————Before actions————————————————————————————————#
	before_action except:[:create] {
		continue_if current_user, is: [:signed_in,:admin], els: simple_back}
	before_action only:[:create] {
		continue_if current_user, is: :signed_in, els: simple_back}

#———————————————————————————————————Actions———————————————————————————————————————#

#---------------------------------- index
	def index
		params[:page]=1 if params[:page]==0 || params[:page].blank?
		params[:selected_feedback]||=0
		params[:feedback_owner_order]||=0
		params[:feedback_talk]||=0
		@pre_selection=arrange_by_token(Feedback.joins(:feedback_call).includes(:feedback_talks),
																		:owner_type, :owner_id)
	end

#---------------------------------- create
	def create
		@feedback=current_user.feedbacks.build
		feedback=current_user.feedbacks.new(feedback_params)
		feedback.save!
		feedback.talk{|filepaths|
										save_object(filepaths, feedback_files, :read)}
		flash[:success]="Messsage Sent"
	rescue ActiveRecord::RecordInvalid,
				 Feedback::TalkSaveFailed,
				 Feedback::CallFailed,
				 Feedback::StatusUpdateFailed => e
		rescue_actions(e,feedback)
		feedback.destroy
	ensure
		in_developement {created_what?(feedback)}
		redirect_back
	end

#---------------------------------- reply
	def reply #validations will have to be javascript
		feedback=Feedback.find_by_id(params[:id])
		stat=feedback.status
		feedback.talk(feedback_params){|filepaths|
										save_object(filepaths, feedback_files, :read)}
		
	rescue ActiveRecord::RecordNotFound,
				 Feedback::TalkSaveFailed,
				 Feedback::CallFailed,
				 Feedback::StatusUpdateFailed => e
		rescue_actions(e,feedback)
	ensure
		in_developement {created_what?(feedback, :reply)
										 updated_to(feedback,stat)} if !stat.blank?
		redirect_back
	end

#---------------------------------- destroy
	def destroy
		feedback=Feedback.find(params[:id])
		if params[:feedback_talk_id].nil?
			path=feedback.filepaths
			if feedback.destroy
				rm_recursive(path, clearbehind: true)
				flash[:success]="Feedback thread destroyed."
				in_developement {flash[:private_messages]=Array(Feedback.filesystem).join}
			end
		else
			talk=FeedbackTalk.find(params[:feedback_talk_id])
			path=feedback.filepaths(talk, :talk)
			if talk.destroy
				rm_recursive(path, clearbehind: true)
				flash[:success]="Feedback message destroyed."
				in_developement {flash[:private_messages]=Array(Feedback.filesystem).join}
			end
		end
	rescue ActiveRecord::RecordNotFound
		flash[:message]="you were trying to destroy a non exsisting object"
	ensure
		redirect_to feedbacks_path
	end

#---------------------------------- mark
	def mark
		feedback=Feedback.find(params[:id])
		stat=feedback.status
		feedback.update_status(feedback_params) {|i| i.call}
		flash[:success]="Feedback status updated"
		in_developement {updated_to(feedback,stat)}
	rescue Feedback::StatusUpdateFailed, Feedback::CallFailed  => e
		flash[:private_terrors]=e.message
	ensure
		redirect_to feedbacks_path
	end

#---------------------------------- attachment
	def attachment
		feedback=Feedback.find(params[:id])
		talks=feedback.feedback_talks.find(params[:talk_id])
		#send_file is a render
		send_file feedback.filepaths(talks)[params[:file_index].to_i]
	end

#———————————————————————————————————Private—————————————————————————#
	private


	def rescue_actions(e,feedback)
		if e.class==ActiveRecord::RecordInvalid
			flash[:terror]=feedback.errors.full_messages
			flash[:error]="Sorry we were not able to send your message, please try again"
		elsif e.class==ActiveRecord::RecordNotFound
			in_developement {
				flash[:private_terrors]="Database conflict: we couldn't find a feedback with such id"}
			flash[:error]="Sorry we were not able to send your message, please try later"
		else
			in_developement {flash[:private_terrors]=e.message}
			flash[:error]="Sorry we were not able to send your message, please try later"
		end
	end

	def created_what?(feedback, op=nil)
			ecre=[]
			flash[:private_messages]=Array(Feedback.filesystem)
			if op!=:reply && !feedback.nil?
				ecre.push("Feedback") if !feedback.id.nil?
				ecre.push("Call")     if !feedback.feedback_call.nil?
			end
			#not good for replies
			if !feedback.nil?
				ecre.push("Talk")     if !FeedbackTalk.find_by_feedback_id(feedback.id).nil?
			end
			flash[:private_messages].push(["Entries created: ", ecre.join(", ")].join)
	end

	def updated_to(feedback, stat)
		if feedback_params[:status]!=stat && stat<4
			if feedback_params[:status]<4
				flash[:private_messages]=["Previous status #{stat}",
				"New feedback status: #{feedback.status}",
				"New call status: #{feedback.feedback_call.status}"].join(", ")
			else
				flash[:private_messages]=["Previous status #{stat}",
				"New feedback status: #{feedback.status}",
				"Call deleted? #{feedback.call_destroyed?}"].join(", ")
			end
		elsif feedback_params[:status]!=stat
			if feedback_params[:status]<4
				flash[:private_messages]=["Previous status #{stat}",
				"New feedback status: #{feedback.status}",
				"Call created? #{feedback.feedback_call.nil?}"]
			else
				flash[:private_messages]=["Previous status #{stat}",
				"New feedback status: #{feedback.status}",
				"No Call created? #{feedback.feedback_call.nil?}"]
			end
		else
			flash[:private_messages]="No status change required"
		end
	end

	#FIXME: do we need to sanitize the incoming files?
	def feedback_files
		params[:feedback][:attachments]
	end

	def feedback_params
		pa={}
		pa[:attachments]=sanitize_filenames_list(feedback_files) if !feedback_files.blank?
		pa[:writer_id]=current_user.id
		pa[:status]=params[:feedback][:status].to_i if current_user.admin?
		pa.or_equal(params[:feedback], [:subject, :to_s], [:text, :to_s])
	end

end