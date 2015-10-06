#load "./app/models/institutional_change.rb"
#load "./app/models/major.rb"
#load "./lib/rails_ext/active_record_preload.rb"
#load "./lib/rails_ext/preload.rb"
#load "overwrite.rb"
#reload!

def exec_my(to_load=true)

=begin

		_institution=Institution.last
		_type=:change_location
		_args       = {type:    _type,
									ielement: _institution,
									reason:  InstitutionalChange::REASONS[_type][0],
									user:    User.first,
									details: {coordinates: [BigDecimal(42.374421 , 10), BigDecimal(-71.118302, 10)],
														updated_at: _institution.updated_at }
									}

		_ichange=InstitutionalChange.new(_args)
		_ichange.valid?

=end


end

exec_my
 