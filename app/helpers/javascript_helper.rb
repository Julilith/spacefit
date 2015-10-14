module JavascriptHelper
	def quoted_j(el)
		raw("'")+escape_javascript(el)+raw("'")
	end
	def quoted(el)
		raw("\"")+el+raw("\"")
	end
	def quoted_raw(quote="\"",el)
		raw(quote)+raw(el)+raw(quote)
	end
end