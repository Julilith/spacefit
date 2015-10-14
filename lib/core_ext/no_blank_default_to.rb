Array.class_eval do

	def no_blank
		self.reject {|x| x.blank?}
	end

	def no_blank!
		self.reject! {|x| x.blank?}
	end

#	def default_to(default, what=:blank?)
#		self.map {|x|     x.send(what) ? default : x}
#	end
#	def default_to!(default, what=:blank?)
#		self.map! {|x|     x.send(what) ? default : x}
#	end

end


Hash.class_eval do

	def no_blank
		self.reject {|x, y| y.blank?}
		end

	def no_blank!
		self.reject! {|x, y| y.blank?}
	end

#	def default_to(default, what=:blank?)
#		Hash[self.map {|x, y|  y.send(what) ? [x, default] : [x, y]}]
#	end
#	def default_to!(default, what=:blank?)
#		self.replace(Hash[self.map {|x, y| y.send(what) ? [x, default] : [x, y]}])
#	end

end

Object.class_eval do
	def no_blank
		self
	end

	def no_blank!
		self
	end

end