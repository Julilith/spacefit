

NilClass.class_eval do
	#NilClass is no integer
	def is_i?
		false
	end
end

Array.class_eval do
	#deletes element at n possition
	def delete_at!(n)
		self.delete_at(n)
		self
	end

	def pretty_print(q)
		breaking=->{q.text(', ') }
		q.group(1, '[',']') {
			q.seplist(self, breaking ) {|v|
				#p v
				q.group(1) {q.breakable ''; q.pp v}
			}
		}
	end

end
