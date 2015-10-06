String.class_eval do
	#check if this sctring shows an integer number
	def is_i?
		!!(self=~/^[0-9]+$/)
	end
	#mix string values between the 's' option
	def shuffle(s="")
		self.split(s).shuffle.join
	end

	#add elements at the beginning and end of string
	# if firrst option is "()", "{}" or "[]" the braketed
	def wrap(ini=nil, fin=nil)
		if ini=="()" || ini=="{}" || ini=="[]"
			return "" if self=="" #dont bracket on empty string
			ini, fin = *ini.split("")
		end
		ini.to_s+self+fin.to_s
	end

	def turn_to_hash
		JSON.parse(self).symbolize_keys
	end


	def is_month?
		["january", "february", "march"    ,
		 "april"  , "may"     , "june"     ,
		 "july"   , "august"  , "september",
		 "october", "november", "december"].include?(self.downcase)
	end

	def is_date?

		self.is_i? || self.is_month?
	end

end