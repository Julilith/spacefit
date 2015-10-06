class TimeTools

	class<<self

		def month_name(val, method=:tap)
			month_list.try(:[], val.to_i-1).try(method){}
		end

		def month_number(val)
			num=month_list.index(val)
			num+1 if !num.nil?
		end

		def months
			month_list
		end

		def is_month?(month)
			month_list.include?(month)
		end

	end

	private
	def self.month_list
		["January", "February", "March"    , "April"  , "May"     , "June",
		 "July"   , "August"  , "September", "October", "November", "December"]
	end
end