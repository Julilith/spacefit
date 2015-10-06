class StaticPagesController < ApplicationController
	include  MyMethods

	def new
	end
	
	def home
		fail
	end

	def help
	end

	def to_fail
		fail
	end

	def about
	end

	def contact
		@feedback=current_user.feedbacks.build
	end

end

