class BaseController < ApplicationController

	def search_remote
		table_name=self.controller_name.capitalize.singularize
		data=InstitutionalName.search_name(params[:hint], like: true)
		respond_to do |f|
			f.js
			f.json {render json: Array(data).map {|i| {label: i.name, value: i.name} } }
		end
	end


private

	def require_disclaimer
		redirect_to root_path if (!current_user.signed_in? || current_user.disclaimer!=true)
	end

	def success_reply(mes="Yeah, we made it!", path_="/")
		_rep={html: [path_], js: {}}
		_rep[:html][1]={flash: {success: mes}} if !mes.blank?
		_rep
	end

	def failure_reply(mes="Opps! something whent wrong...", path_="/")
		_rep={html: [path_], js: {}}
		_rep[:html][1]={flash: {error: mes}} if !mes.blank?
		_rep
	end

	def reply(options_={})
		respond_to do |format|
			format.html {redirect_to *options_[:html] }
			format.js {}
		end
	end

	def reply_on(ops_={})
		reply( ops_[:error] ? failure_reply(*[*ops_[:error] , ops_[:redirect_to]]) :
												 success_reply(*[*ops_[:success], ops_[:redirect_to]]) )
	end


end