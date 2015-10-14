Object.class_eval do

	def no(what=:tap)
		if !what.kind_of?(Array) || !what.kind_of?(Hash)
			what=[:==, what]
		end
		if self.kind_of?(Array)
			self.reject {|x| x.send(*Array(what)){}}
		elsif self.kind_of?(Hash)
			self.reject {|x, y| y.send(*Array(what)){}}
		else
			self
		end
	end

	def map_with_index(&block)
		self.map.each_with_index &block
	end


	def gmethods(val)
		self.methods.grep /#{val.to_s}/
	end

	def ivars(val=nil, opts_=nil )
		ivars=self.instance_variables

		return ivars if !val

		nvars=if val.kind_of?(Fixnum)
						[ivars[val]]
					else
						ivars.grep /#{val.to_s}/
					end

		if nvars.count>1
			if opts_.kind_of?(Hash) && opts_[:i].kind_of?(Fixnum)
				nvars=[ nvars[opts_[:i]] ]
			else
				return nvars
			end
		end

		return [] if nvars.count==0

		if nvars.count==1
			if opts_.kind_of?(Hash) && opts_.include?(:v)
				self.instance_variable_set(nvars[0], opts_[:v])
			else
				puts nvars[0]
				self.instance_variable_get(nvars[0])
			end
		end

	end



end
