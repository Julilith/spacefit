class StaticPagesController < ApplicationController
	include  MyMethods

	def new
	end
	
	def home
	end

	def help
	end

	def to_fail
	end

	def about
	end

	def contact
		@feedback=current_user.feedbacks.build
	end

end

