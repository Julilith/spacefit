	#basemodel
	# because these triggered a trasaction even when not valid!
	def save(options={validate: true})
		if options[:validate]
			self.valid? ? super(options) : false
		else
			super(options)
		end
	end

	def save!(options={validate: true})
		if options[:validate]
			self.valid? ? super(validate: false) :
														 raise(ActiveRecord::RecordInvalid.new(self))
		else
			super(options)
		end
	end

	#---------------------------------- Complex joins
	#doesnt work with eager_load!!!!
	def self.complex_joins(*args)
		name_ass, join_type= args[0].kind_of?(Array) ? args[0] : [args[0],"INNER JOIN"]
		main_sql     =self.joins(name_ass).to_sql
		init_join_sql=join_type+main_sql[/(?<=INNER JOIN).*/]
		name         =init_join_sql[/\".*\"(?=\s*ON)/]
		join_sql_son =init_join_sql.split("ON")
		on_post_sql  =join_sql_son[1]
		on_prev_sql =join_sql_son[0]+"ON "
		sql_add=args[1..-1].map{ |v, t, z|
			puts [v, t, z].inspect
			v.kind_of?(Array) ? (op=v[1]; v=v[0]) : op="="
			if    (t=="OR" || t.nil?)
				" #{t || " AND "} #{v}"
			elsif t.kind_of?(Array)
				t=t.map{|i| !i.kind_of?(Fixnum) ? sanitize(i) : i}.join(",").wrap("()")
				" #{z || "AND"} #{name}.#{v.to_s} IN #{t}"
			elsif t.kind_of?(Symbol)
				t=sanitize(t.to_s)
				" #{z || "AND"} #{name}.\"#{v.to_s}\" #{op} \"#{self.table_name}\".#{t}"
			else
				t=sanitize(t.to_s) if !t.kind_of?(Fixnum)
				" #{z || "AND"} #{name}.\"#{v.to_s}\" #{op} #{t.to_s}"
			end
			}
		self.joins(on_prev_sql+[on_post_sql, sql_add].no_blank.join() )
	end
