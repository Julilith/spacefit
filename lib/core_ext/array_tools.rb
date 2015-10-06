class ArrayTools
	# turns propperly formatted arrays -each element must be an array of length 2!-
	# into an hash
	# PARAMETERS
	# *hash_on allows to set on what types of keys hasshing is allowed on
	## ATTENTION
	## =>if an hash is found is passed by default and key type is not checked
	## =>the method uses the hash method ".merge"
	def self.to_hash(obj, *hash_on)
		hash={}
		if self.hashable(obj,*hash_on)
			# check if hashable
			hash[obj[0]]=(self.to_hash(obj[1],*hash_on))
		elsif !obj.kind_of?(Array)
			# cannot be hashable (not an array), return the object
			hash=obj
		else
			# search array
			hash_found=false
			Array(obj).each do |i|
				new_obj=self.to_hash(i,*hash_on)
				if new_obj.kind_of?(Hash)
					# if hash found say it and merge it
					hash_found=true
					hash.merge!(new_obj)
				end
			end
			#return obj if there were no hashable elements
			hash=obj if !hash_found
		end
		hash
	end
	private
	def self.hashable(obj, *on)
		# if array of length 2 and the first element is not an array or else any
		# of the types defined in *on
		if obj.kind_of?(Array)
			# default only check that key elements are not arrays
			hashable_type=( on==[] ? !obj[0].kind_of?(Array) : false )
			on.each do |i|
				# check if key is of the type required
				hashable_type||=obj[0].kind_of?(i)
			end
			val=true if obj.count==2 && hashable_type
		end
	end
end