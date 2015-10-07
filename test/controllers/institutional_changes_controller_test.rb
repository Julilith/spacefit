require 'test_helper'

class InstitutionalChangesControllerTest < ActionDispatch::IntegrationTest

	def setup
		@allowed_languages=InstitutionalNameJoin::LANGUAGE_SAVABLE
		@names=["test1_n","test1_1", "test1_2","test1_4", "new_nname"]

	#user, create and loging
		@user           = User.new(email: "user@user.user", provider: "facebook")
		token=@user.sessions.new
		cookies[:token] = token.value
		@user.save!

	#parent institution
		@institution=Institution.new(iname: {name: @names[0], language: @allowed_languages[0]},
																 website: "test@test.test")
		@institution.save!

	#parent department
		@department=Department.new(iname: {name: @names[0], language: @allowed_languages[0]})
		@department.save!
	end

	test "new_element" do
		_details    = {type: 'Department' , language: "english", name: @names[1]}
		_all_params = all_params(@institution, type: :new_element.to_s,
																					 reason: "doesn't exists",
																					 details: _details)

		_pass=assert_difference('InstitutionalChange.count') do
			post to_path(@institution.id, :new_element), _all_params
		end

	end


	test "change_visible" do
		_details    = {visible: "false"}
		_all_params = all_params(@department, type: :change_visible.to_s,
																					reason: "doesn't exists",
																					details: _details)

		assert_difference('InstitutionalChange.count') do
			post to_path(@institution.id, :change_visible), _all_params
		end
		@department.reload
		@department.visible=true
		@department.save
	end

	test "new_language" do
		@institution.reload

		_details    = {language: @allowed_languages[1], name: @names[0]}
		_all_params = all_params(@institution, type:   :new_language,
																					 reason: "was missing",
																					 details: _details)

		assert_difference('InstitutionalChange.count') do
			post to_path(@institution.id, :new_language), _all_params
		end

	end


	test "change_name" do
		InstitutionalName.new(name: @names[1]).save!
		@department.reload

		_details    = {language: @allowed_languages[0], name: @names[1]}
		_all_params = all_params(@department, type:   :change_name,
																					reason: "not quite right",
																					details: _details)

		assert_difference('InstitutionalChange.count') do
			post to_path(@institution.id, :change_name), _all_params
		end
	end


	test "change_location" do
		_institution=Institution.last
		_type=:change_location
		_all_params= all_params(_institution,
														type:    _type,
														reason:  InstitutionalChange::REASONS[_type][0],
														details: {#latitude: "42.374421",
																			longitude: "-71.118302"}
														)

		#fail is data missing (probably excessive check)

		assert_no_difference('InstitutionalChange.count') do
			post to_path(@institution.id, _type), _all_params
		end

		#fail if not the proper format
		_all_params[:institutional_change][:details][:latitude]="23"
		assert_no_difference('InstitutionalChange.count') do
			post to_path(@institution.id, _type), _all_params
		end


		_all_params[:institutional_change][:details][:latitude]="42.374421"
		assert_difference('InstitutionalChange.count') do
			post to_path(@institution.id, _type), _all_params
		end
	end

private

	def basic_params(institution_)
		{institutional_change: 
			{ ielement_id:   institution_.id.to_s        ,
				ielement_type: institution_.class.name.to_s,
				details: {updated_at: institution_.last_changed}
			}
		}
	end

	def all_params(ielement_, ops_)
		_new_params=basic_params(ielement_).dup
		_new_params[:institutional_change].merge!(ops_.except(:details))
		_new_params[:institutional_change][:details].merge!(ops_[:details])
		_new_params
	end

	def to_path(id_, action_)
		"/institutions/#{id_}/#{action_}"
	end


end