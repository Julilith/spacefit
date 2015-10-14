class UserSessionTest < ActiveSupport::TestCase


	def setup
		@allowed_languages=InstitutionalNameJoin::LANGUAGE_SAVABLE
		@names=["test1_n","test1_1", "test1_2","test1_4", "new_nname"]

	#user
		@user=User.new(email: "user@user.user", provider: "facebook")
		@user.save!
	#parent institution
		@institution=Institution.new(iname: {name: @names[0], language: @allowed_languages[0]},
																 website: "test@test.test")
		@institution.save!

	#departments and majors
		@dep_1={department:{ name: @names[1], language: @allowed_languages[0] }}
		@maj_1={major: { name: @names[2], language: @allowed_languages[0]}}
		@department_1=@institution.build_branch(@dep_1.merge(@maj_1)).departments.target[0]
		@department_1.save!

	#basics
		@basic_args={user: @user, ielement: @department_1}
	end

	# reason must be valid or else nothing will happen
	test "set_type_and_reason" do 
		types       =InstitutionalChange::TYPES
		reasons     =InstitutionalChange::REASONS
		type_index  =rand(types.count)
		type        =types[type_index]

		reason_index=rand(reasons[type].count)
		reason= reasons[type][reason_index]

		dat={type: type, reason: reason}

		_ichange=@institution.ichanges.new(type: dat[:reason], reason: dat[:type])
		assert(_ichange.type.nil? && _ichange.reason.nil?)
		_ichange=InstitutionalChange.new(type: dat[:reason], reason: dat[:reason])
		assert(_ichange.type.nil? && _ichange.reason.nil?)
		_ichange=InstitutionalChange.new(type: dat[:type], reason: dat[:type])
		assert(_ichange.type.nil? && _ichange.reason.nil?)
		_ichange=InstitutionalChange.new(type: dat[:type], reason: dat[:reason])
		assert(_ichange.type_index==(type_index+1) && _ichange.reason_index==(reason_index+1))
	end

	test "users_must_be_present_in_the_database" do
		_ichange=InstitutionalChange.new(@basic_args.merge({details: {type: 'Department'}}))
		_ichange.user = User.new
		assert(!_ichange.valid?)

	end



	test "belongs_to_user_and_ielement" do
		_ichange=InstitutionalChange.new(@basic_args)

		assert(_ichange.user_id==@user.id                                   &&
					 _ichange.institutional_element_type==@department_1.class.name &&
					 _ichange.institutional_element_id==@department_1.id)
	end

	# reason must be valid or else nothing will happen
	test "change_visible" do

		_department=Department.where(id: @department_1.id)[0]
		_args={type:     :change_visible,
					 reason:  "doesn't exists",
					 user:     @user,
					 ielement: _department,
					 details: {visible:    true,
										 updated_at: _department.updated_at} }
		_ichange=InstitutionalChange.new(_args)

	# if change identical to state gives error
		assert_raises InstitutionalChange::InstitutionalChangeError do
			_ichange.execute_change
		end

		#hide
		_ichange.change_details(visible: false)
		_ichange.execute_change

		assert(_department[:visible] == false                     &&
					 _ichange.previous_state.turn_to_hash[:visible]==true 
					 )
		#show again
		_ichange.change_details(visible: true, updated_at: _department.reload.updated_at)
		_ichange.execute_change
		assert(_department[:visible] == true                     &&
					 _ichange.previous_state.turn_to_hash[:visible]==false
					)

	end


	test "ielement_must_be_visible" do
		@department_1[:visible]=false
		_args       = {type:    :change_name,
									reason:  InstitutionalChange::REASONS[:change_name][0],
									ielement: @department_1
									}
		_ichange=InstitutionalChange.new(_args)

		assert_raises InstitutionalChange::InstitutionalChangeError do
			_ichange.execute_change
		end
		@department_1[:visible]=true
	end

	test "ielement_parent_must_be_visible" do
		@department_1[:visible]=false
		_args       = {type:    :change_name,
									reason:  InstitutionalChange::REASONS[:change_name][0],
									ielement: @department_1.majors[0]
									}
		_ichange=InstitutionalChange.new(_args)
		assert_raises InstitutionalChange::InstitutionalChangeError do
			_ichange.execute_change
		end
		@department_1[:visible]=true
	end


	test "change_name" do
		_new_name  = "asdfasdf"
		join_lang = @department_1.iname_joins.target[0].language
		@department_1=Department.where(id: @department_1.id,
																	 institutional_name_joins: {language: join_lang} ).
														eager_load(institutional_name_joins: :iname)[0]

		iname_join = @department_1.iname_joins[0]
		iname      = iname_join.iname
		@basic_args[:ielement]=@department_1

		args_       = {type:    :change_name,
									reason:  InstitutionalChange::REASONS[:change_name][0],
									details: {language:   join_lang,
														name:       iname.name,
														updated_at: @department_1.updated_at}
									}.merge(@basic_args)

		_ichange=InstitutionalChange.new(args_)

	#if name identical raise error
		assert_raises InstitutionalChange::InstitutionalChangeError do
			_ichange.execute_change
		end

	#if language not matching gives error
		_ichange.change_details(name: "asdflksdf", language: @allowed_languages[1])

		assert_raises InstitutionalChange::InstitutionalChangeError do
			_ichange.execute_change
		end

	#It should work
		_ichange.change_details(name: _new_name, language: @allowed_languages[0])
		_ichange.execute_change
		_iname_joins=_ichange.ielement.institutional_name_joins.
													where(language: args_[:details][:language])
		_iname=_iname_joins[0].iname

		assert( _iname_joins.length==1   &&
						_iname.name == _new_name &&
					 !_iname.new_record?       &&
						_iname.id   == _iname_joins[0].institutional_name_id)
	#ichange was created on new iname
	end

	test "new_language" do
		_new_name="oimcdl"
		join_lang = @department_1.iname_joins.target[0].language
		@department_1=Department.where(id: @department_1.id)[0]

		@basic_args[:ielement]=@department_1

		args       = {type:    :new_language,
									reason:  InstitutionalChange::REASONS[:new_language][0],
									details: {language:   join_lang,
														name:       _new_name,
														updated_at: @department_1.updated_at}
									}.merge(@basic_args)

	#If language already exsists for element it should fail
		_ichange=InstitutionalChange.new(args)

		assert_raises InstitutionalChange::InstitutionalChangeError do
			_ichange.execute_change
		end

	#it should work
		_major=@department_1.majors[0].reload
		_ichange.ielement=_major
		_ichange.change_details(language: @allowed_languages[1], updated_at: _major[:updated_at])
		_ichange.execute_change


		_new_join=_major.iname_joins.target[0]
		_previous_state={name: _new_name, language: @allowed_languages[1] }
		assert( !_new_join.new_record?                     &&
						 _new_join.language==@allowed_languages[1] &&
						!_new_join.iname_target.new_record?        &&
						 _new_join.iname_target.name==_new_name    &&
						!_ichange.new_record?                      &&
						_ichange.previous_state_hash==_previous_state
						)
	end

	test "add_iname" do

		#if loaded from database ichange is not created on iname
		_name=InstitutionalName.last
		_ichange=InstitutionalChange.new(user: @user).add_iname(_name)
		assert(_name.ichanges.target.blank?)

		#if name saved before without ichange ichange is not saved
		_name     =InstitutionalName.new(name: "olkjnsdf")
		_ichange  =InstitutionalChange.new(user: @user).add_iname(_name)
		_ichange_2=InstitutionalChange.new(user: @user).add_iname(_name)
		assert(_name.ichanges.target.count==1)

		# you can only add one ichange to iname
		_name   =InstitutionalName.new(name: "lkjouin")
		_ichange=InstitutionalChange.new(user: @user).add_iname(_name)
		_name.save!
		assert(!_ichange.new_record? && _ichange.institutional_element_id==_name.id)

	end

	test "change_location" do
		_institution=Institution.last
		_type=:change_location
		_args       = {type:    _type,
									ielement: _institution,
									reason:  InstitutionalChange::REASONS[_type][0],
									user:    @user,
									details: {coordinates: [BigDecimal(42.374421 , 10), BigDecimal(-71.118302, 10)],
														updated_at: _institution.updated_at }
									}
		_ichange=InstitutionalChange.new(_args)
		_ichange.execute_change
		_ichange_address_1=_ichange.ielement.locations[0].address

		assert(!_ichange.new_record?                       &&
					 !_ichange.ielement.locations[0].new_record? &&
					  _ichange.ielement.locations[0].address!="unknown")

		#this should fail because identical to previousS
		_args[:ielement]=_institution=Institution.last
		_args[:user]    = User.first
		_args[:details][:updated_at]=_institution.updated_at
		_ichange=InstitutionalChange.new(_args)

		assert_raises InstitutionalChange::InstitutionalChangeError do
			_ichange.execute_change
		end

		#this should pass
		_institution=Institution.last
		_args[:ielement]=_institution
		_args[:user]    = User.first
		_args[:details][:updated_at] = _institution.updated_at
		_args[:details][:coordinates]= [BigDecimal(35.673877, 10), BigDecimal(139.478935, 10)]

		_ichange=InstitutionalChange.new(_args)
		_ichange.execute_change

		assert(!_ichange.new_record?                        &&
					 !_ichange.ielement.locations[0].new_record?  &&
					  _ichange.ielement.locations.length==1       &&
					  _ichange.ielement.locations[0].address!="unknown" &&
					  _ichange.ielement.locations[0].address!=_ichange_address_1)
	end

	test "new_element" do

		@child_data={type: "major"}.merge(@maj_1[:major])
		_department=Department.where(id: @department_1.id)[0]
		_args={type:    :new_element,
					ielement: _department,
					reason:   InstitutionalChange::REASONS[:new_element][0],
					details:  @child_data.merge({updated_at: _department.updated_at}),
					user:     @user}


	# if matching record was already found and it was visible fail
		_ichange=InstitutionalChange.new(_args)

		assert_raises InstitutionalChange::InstitutionalChangeError do
			_ichange.execute_change
		end

	#It should work: if matching record was already found and it was not visible
		Major.first.update_attribute(:visible, false)
		_ichange=InstitutionalChange.new(_args)
		_ichange.execute_change

		assert(!_ichange.new_record?           &&
						_ichange.type==:change_visible && _ichange.ielement.visible)

	#It should work
		_department=Department.where(id: @department_1.id)[0]
		_ichange=InstitutionalChange.new(_args)
		_ichange.ielement=_department
		_ichange.change_details(type: "major", language: @allowed_languages[2])
		_ichange.execute_change

		_child=_department.majors[0]

		_previous_state=@child_data.except(:updated_at).merge({new_record_id: _child.id})
		_previous_state[:language]=@allowed_languages[2]

		assert(!_ichange.new_record? &&
						_ichange.previous_state.turn_to_hash==_previous_state &&
						!_ichange.ielement.send(_previous_state[:type].pluralize)[0].new_record?
						)
	end

	test "all_inames_have_only_one_ichange" do
		_inames=InstitutionalName.where.not(name: @names[0..2]).eager_load(:ichanges)
		#this works on test environment
		count=_inames.map { |iname_| iname_.ichanges.length<=1 }.inject(:&)
		assert( count ? count : true )
	end

end
