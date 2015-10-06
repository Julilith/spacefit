class Basemodel < ActiveRecord::Base
	include MyMethods
	include Token

	attr_accessor :destroyed, :stored_ass, :record_already_validated, :record_in_validation
	self.abstract_class = true
	MAXSUGGESTIONS=10;
	APPSAVEDIR=File.join(Rails.root,"app","assets")



	#---------------------------------- preload
	def self.load_joins(arg)
		joins(arg).eager_load(arg)
	end

	#---------------------------------- save_changed
	# pass an hash with attriutes, if the attributes.
	# It will set only the attributes that belong to the record without failing
	# also marks the change for any non identical change (where Rails still fails)
	def save_changed(changes)
		changes.each do |attribute, val|
			if self.has_attribute?(attribute)
				if self[attribute]!=val
					cname=(attribute.to_s+"_will_change!").to_sym
					self.send(cname)
					self[attribute]=val
				end
			else
				puts "\'#{attribute}\' is not an attribute of #{self.class.name}"
			end
		end
		self.save if self.changed?
	end

	#---------------------------------- identify
	# usefull to check the identity from polymorfic associations
	def identify
		[self.class, self.id]
	end


	#---------------------------------- matches?
	# check if records are the same (without checking for changed attributes)
	def matches?(record)
		self.identify==record.identify
	end


	#---------------------------------- map & values_at
	def values_at(*keys)
		self.slice(*keys).values
	end

	def map
		self.attribute_names.map do |i|
			yield self, i if block_given?
		end
	end


	#---------------------------------- Pagination & search tools
	def self.base_pagination(page, op={pp: 5})
		op[:pp]||=5
		paginate(page: page, per_page: op[:pp], total_entries: op[:max])
	end

	def self.paginate_search(key,page,op={})
		self.search(key, op[:limit]).base_pagination(page,op)
	end

	def self.search(val="", limit=nil)
		if !val.blank?
			send_to= limit.blank? ? [:tap] : [:limit, limit]
			self.where("name LIKE ?",  "%"+"#{val}".split("").join("%")+"%").send(*send_to) {}
		else
			self
		end
	end

	#---------------------------------- Pagination tools
#	def destroyed?
#		self.destroyed==true
#	end

	def create_filepath_list(path, filenames)
		filenames.blank? ?
		path : filenames.split(";").map {|i| file_join(path, i)}
	end


	#---------------------------------- a method to store queries with where
	include MonkeyRecord::Preload

	#---------------------------------- disable timestamps

	def disable_timestamps(&block)
		self.record_timestamps=false
		yield
		self.record_timestamps=true
	end

	def as_new_record(&block)
		is_new=self.instance_variable_get(:@new_record)
		self.instance_variable_set(:@new_record, true) if !is_new
		yield
		self.instance_variable_set(:@new_record, false) if !is_new
	end

	def manual_load(ass_, recs_=nil)
		ass_=ass_.to_sym
		self.as_new_record do
			_association=self.association(ass_)
			_target=_association.target
			if !recs_.blank?
				if _target.kind_of?(Array) 
					self.send(ass_).target.push(*recs_)
				else
					_association.target=recs_
				end
			end
			_association.loaded!
		end
			recs_
	end

	#---------------------------------- Save at given version
	# done by locking save in a trassaction with parent updated at time
	class IncorrectVersion < StandardError; end

	def lock_at_version(time=nil, also_update={})
		_id   = self.id
		_time = time || self.updated_at

		_updated=self.class.where(id: _id, updated_at: _time).
												update_all(updated_at: Time.now.utc)

		raise IncorrectVersion if _updated == 0
	end

	def last_changed
		self.updated_at.strftime("%Y-%m-%d %H:%M:%S.%6N")
	end

	#---------------------------------- Owner methods
	def self.owner_methods(name_="owner", keys_=["owner_id", "owner_type"], slaves_ )
	end

	#---------------------------------- Owner methods
	def self.create_relation(records_)
		_relation = self::ActiveRecord_Relation.new(self, self.arel_table)
		_relation.instance_variable_set(:@loaded,true)
		_relation.instance_variable_set(:@records, records_)
		_relation
	end


end
