Hash.class_eval do
	# moking of ||= for internal hash elements with options
	# to           => optional hash
	# using the "take_all: true" option sets all keys of to as what
	# what[n,1]=tk => hash to ad from 'to' if not exsists
	# what[n,2]=sf => if present is equal to write 'to[tk].send(sf)'
									#of 'sf.call(to[tk])'
	#ex: {a: 1, b: 2}.or_equal({c: 2, d: 3}, [c:, :to_s])
		##=>{a: 1, b: 2,c: 2}
		#preexsisting value in 'self' takes precedence 
		#the method works even if the hash key declared does is not
			#part of 'to'
	#TODO add a condition on the nature of the initial values
		#of 'self'
	def or_equal(to, *what)
		raise ArgumentError, "you need to provide at least a key" if what.blank?
		rails ArgumentError, "first parameter not an Hash"        if !to.kind_of?(Hash)
		options=what.extract_options!
		if !options.blank?
			what=to.keys if options[:take_all]
		end
		pass=self.except(*what)
		what.each do |i, j|
			self_value=self[i]
			to_value=  to.send(:[],i)
			send_what= j.nil? ? :tap : j
			if send_what.kind_of?(Proc)
				pass[i]=send_what.call(to_value)   {} if  self_value.blank? && !to_value.blank?
				pass[i]=send_what.call(self_value) {} if !self_value.blank?
			else
				pass[i]=to_value.send(send_what)   {} if  self_value.blank? && !to_value.blank?
				pass[i]=self_value.send(send_what) {} if !self_value.blank?
			end
		end
		pass
	end

	def or_equal!(to, *what)
		self.replace(self.or_equal(to, *what))
	end

	#Set hash value if not blank
	def setnb(op)
		op.each do |key, val|
		self[key]=val if !val.nil?
		end
		self
	end

	def to_array
		self.map do |i,j|
			met=j.kind_of?(Hash) ? :to_array : :tap
			[i,j.send(met){}]
		end
	end

		def map_hash(&block)
			enum_map=super 
			Hash[enum_map]
		end

end