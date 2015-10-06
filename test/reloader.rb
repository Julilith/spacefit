class Reloader

	attr_accessor :file_cache, :file_names
	def initialize(*dir_)
		@file_names=[]
		@file_cache={}
		dir_.each do |d_|
			@file_names.push *Dir.glob(File.join(Rails.root, d_, "/*.rb" ) )
		end
		@file_names.each {|fname_| @file_cache[fname_]=File.mtime(fname_)}
		"done"
	end

	def reload
		@file_cache.each do |fkey_, time_|
			_mtime=File.mtime(fkey_)
			if _mtime!= time_
				_fname=File.basename(fkey_, ".rb")
				_obj=_fname.camelize.to_sym

				if Object.constants.include?(_obj)
					Object.send(:remove_const, _obj)
					load File.basename(fkey_)
					@file_cache[fkey_]=_mtime
					lput "Reload: #{fkey_}"

				end

			end
		end

		return

	end

private
	def remove_constant(cons_)
		ActiveSupport::Dependencies.remove_constant(cons_) 
	end

end

def reloader_initialize
	@reloader_instance=Reloader.new('app/controllers','app/models');
end

def reload_
	@reloader_instance.reload
end

