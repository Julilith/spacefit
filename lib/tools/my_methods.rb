module MyMethods
	#require 'core_ext'

	NPOSTS=20
	APPSAVEDIR=File.join(Rails.root,"app","assets")

	def itself_or(a, b); a.blank? ? b : a;        end
	def xor(a,b);      (a && !b) || (!a && b); end

	def sanitize_merge_or(inith, hash={} )
		if hash.to_a.first.second.blank?
			inith
		else
			newh=hash.to_a.map do 
				|i, j| inith.merge({i => sanitize_original_filename(j)})
			end
			newh.first
		end
	end

	def create_filepath(record, op={})
		#options are :second_key (default 0) and :filenames (default nil)
		#:sencond_key is the reply number-> has to be a positive integer from 0 (?)
		#:filenames option takes presedence over record.attachments
		case record.class.name
		when "User" # picture model has to be reformatted for better
			#the path property should be a property of each model<<<<<<<========== FIX ME
			File.join(APPSAVEDIR,'avatars',
							record.class.name,
							record.id.to_s,
							record.avatar.nil? ? "" : record.avatar)
		else
			raise NoPathForModel, 'There is no Filesytem structure for such object'
		end
	end

	def file_join(*a)
		File.join(*(a.map {|i| i.to_s}))
	end

	def delete_all_files(fullpath)
		begin
			allowed_path(fullpath)
			Dir.glob(File.join(fullpath, "*")) do |f|
				begin
					File.delete(f)
				rescue Errno::EACCES => e
					puts e.message
					next
				end
			end
		rescue NotAllowedPath
		end
	end

	def delete_file(fullpath)
		begin
			allowed_path(fullpath)
			path=File.split(fullpath)
			returndir=Dir.pwd
			Dir.chdir(path[0])
			File.delete(path[1])
			Dir.chdir(returndir)
			rm_recursive(path[0])
		rescue NotAllowedPath
		end
	end

	#recurseve remove directories <<< needs work!
		#define allowed_paths
		class NotAllowedPath < StandardError; end
		def allowed_path(path)
			unless path =~/#{APPSAVEDIR}#{File::SEPARATOR}.*/
				raise NotAllowedPath, "#{path} is out of the allowed_paths: #{APPSAVEDIR}"
			end
		end

		#removes empty directories
		def rm_clearbehind(dir)
			allowed_path(dir)
			if Dir.entries(dir)[2].nil?
				parent=File.split(dir)[0]
				#If Dir.pwd is in the way, I am going back
				Dir.chdir(parent) if Dir.pwd =~/#{dir}.*/
				Dir.rmdir(dir)
				rm_clearbehind(parent)
			end
		rescue NotAllowedPath
		rescue Errno::ENOENT
			# log the directory does not exsist, possible broken filesystem
			rm_clearbehind(File.split(dir)[0]) 
		end

		def rm_recursive(dir, initio=true, op={clearbehind: false})
			#check if path is deletable
			allowed_path(dir) 
			try_again=false
			#changest current directory out of the deleting path
			if initio
				if Dir.pwd =~/#{dir}.*/
					Dir.chdir(File.split(dir)[0]) 
				end
			end
			#start to rm dir and clear behind
			if initio && try_again
				rm_clearbehind(dir)
			else
				Dir.rmdir(dir)
			end
			true
			# Errno::EACCES is an error that happens if the object is in use by an other program
		rescue Errno::EACCES, Errno::ENOTEMPTY => e # if dir not empty
			Dir.entries(dir)[2..-1].each do |i|
				rm_recursive(File.join(dir, i), false)
			end
			try_again=true if op[:clearbehind]
			retry
		rescue NotAllowedPath => e# not an allowed path
			e.message
		rescue Errno::ENOTDIR
			if initio
				# log message >>> "you are trying to delete a file not a directory"
			else
				File.delete(dir)
				#puts "file #{dir} removed"
			end
		rescue Errno::ENOENT
			# log the directory does not exsist, possible broken filesystem
		end

		#recurseve define directories 
	def mkdir_recursive(path) #attention it takes an array
		listp=path.split(File::SEPARATOR)
		returndir=Dir.pwd
		Dir.chdir(listp[0]<<"/")
		listp.each do |pt|
			Dir.mkdir(pt) if !Dir.exist?(pt)
			Dir.chdir(pt)
		end
		Dir.chdir(returndir)
	end

	# methods to save one or multiple objects
	def no_method
		self 
	end

	def save_object(fullnames, objects, method=:no_method)
		#TODO: raise exception if saving fails
		#fullnames should be sanitized with outputs an array
		#objects are as default uploaded as an array
		ns=[]
		fullnames.each_with_index do |o, i|
			begin
				mkdir_recursive(File.split(o)[0])
				f=File.open(o, "wb")
				f.write(Array(objects)[i].send(method))
				f.close
			rescue Errno::EINVAL => e
				ns.push(o) #list of not savable files
			end
		end
		true
	end


	#pass the array to arrange (arg) and the arranging functions (*orfa) as symbols
	#Ex: arrange_by_token(array, :first_condition, :second_condition)
	#FIXME: It can be infinitelly recursive but needs double check
	#       Cannot choose options for orfa
	def arrange_by_token (arg, *orfa)
		argn=[]
		ordli={}
		inx=0
		orf=orfa.first
		arg.each do |f|
			i=f.send(*orf)
			if ordli[i].nil?
				argn.push([f])
				ordli[i]=inx
				inx+=1
			else
				argn[ordli[i]].push(f)
			end
		end
		if orfa.count>1
			argn.each_with_index do |f,i|
				argn[i]=arrange_by_token(f, *orfa[1..-1])
			end
		else
			return argn
		end
	end

	def sanitize_filename(object)
		# Split the name when finding a period which is preceded by some
		# character, and is followed by some character other than a period,
		# if there is no following period that is followed by something
		# other than a period (yeah, confusing, I know).
		object.sub! /\A.*(\\|\/)/, ''
		object.gsub!(/[\\\/\:\*\%\"\'\|\<\>\s\?\!\@\[\]\(\)\#\$\&\;\n]/, "")
		object.gsub!(/\.{2}/, "") #this last two are not working properly
		object.gsub!(/\_{1}/, "_")
		if object==""
			[*('a'..'z'), *(1..9)].sample(6)
		else
			object
		end
	end

	def sanitize_original_filename(object)
		sanitize_filename(object.original_filename) if !object.blank?
	end

	def sanitize_filenames_list(lista)
		if !lista.blank?
			atta=""
			lista.each {|i| atta<<sanitize_original_filename(i) + ";"}
			atta=atta[0..-2]
		else
			nil
		end
	end

end