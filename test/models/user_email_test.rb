
require 'test_helper'

class UserEmailTest < ActiveSupport::TestCase


	def setup
		@ilangs=InstitutionalNameJoin::LANGUAGE_BASIC
		@institution=Institution.new(iname: {name: "test1_n", language: @ilangs[0]},
																 website: "test@test.test")
		@dep_1={department: {name: "test1_1", language: @ilangs[0] }}
		@dep_2={department: {name: "test1_2", language: @ilangs[0] }}
		@maj_1={major: {name: "test1_3", language: @ilangs[0]} }
		@maj_2={major: {name: "test1_3", language: @ilangs[0]} }

		@institution.save!

	end

	#test the setting of attributes
	test "build_branch" do
		branch=@institution.build_branch(@dep_1.merge(@maj_1))
		branch.save!
		dep=@institution.departments.target[0]
		dep_iname=dep.to_inames(:target)[0]
		maj=dep.majors.target[0]
		maj_iname=maj.to_inames(:target)[0]
		assert (!dep.new_record? && !dep_iname.new_record? &&
						!maj.new_record? && !maj_iname.new_record?    )

		@institution.reload.build_branch(@dep_2).save!
		dep      =@institution.departments.target[0]
		dep_iname=dep.to_inames(:target)[0]
		assert (!dep.new_record? && !dep_iname.new_record?)

		@institution.build_branch(@maj_2).save!
		maj       =@institution.majors.target[0]
		maj_iname =maj.to_inames(:target)[0]
		assert (!maj.new_record? && !maj_iname.new_record?)
	end

	test "get_branch" do
		@institution.build_branch(@dep_1.merge(@maj_1)).save!
		@institution.build_branch(@dep_2.merge(@maj_2)).save!

	#test instance method: get_branch
		@institution.reload
		@institution.get_branch

		assert (@institution.departments.loaded?                                       &&
						@institution.departments[0].iname_joins.loaded?                        &&
						@institution.departments[0].iname_joins[0].association(:iname).loaded? &&
						@institution.departments[0].majors.loaded?                             &&
						@institution.departments[0].majors[0].iname_joins.loaded?              &&
						@institution.departments[0].majors[0].iname_joins[0].association(:iname).loaded? )
		@institution=Institution.get_branch[0]
		assert (@institution.departments.loaded?                                       &&
						@institution.departments[0].iname_joins.loaded?                        &&
						@institution.departments[0].iname_joins[0].association(:iname).loaded? &&
						@institution.departments[0].majors.loaded?                             &&
						@institution.departments[0].majors[0].iname_joins.loaded?              &&
						@institution.departments[0].majors[0].iname_joins[0].association(:iname).loaded? )

	#test instance method: get_branch with visible option
		@institution.reload
		@institution.get_branch(visible: true)
		assert (@institution.departments.loaded?                                       &&
						@institution.departments[0].iname_joins.loaded?                        &&
						@institution.departments[0].iname_joins[0].association(:iname).loaded? &&
						@institution.departments[0].majors.loaded?                             &&
						@institution.departments[0].majors[0].iname_joins.loaded?              &&
						@institution.departments[0].majors[0].iname_joins[0].association(:iname).loaded? )
		@institution=Institution.get_branch[0]
		assert (@institution.departments.loaded?                                       &&
						@institution.departments[0].iname_joins.loaded?                        &&
						@institution.departments[0].iname_joins[0].association(:iname).loaded? &&
						@institution.departments[0].majors.loaded?                             &&
						@institution.departments[0].majors[0].iname_joins.loaded?              &&
						@institution.departments[0].majors[0].iname_joins[0].association(:iname).loaded? )


	#test class method: get_branch
		@institution=Institution.get_branch(id: @institution.id)[0]
		assert (@institution.departments.loaded?                                       &&
						@institution.departments[0].iname_joins.loaded?                        &&
						@institution.departments[0].iname_joins[0].association(:iname).loaded? &&
						@institution.departments[0].majors.loaded?                             &&
						@institution.departments[0].majors[0].iname_joins.loaded?              &&
						@institution.departments[0].majors[0].iname_joins[0].association(:iname).loaded? )
		@institution=Institution.get_branch[0]
		assert (@institution.departments.loaded?                                       &&
						@institution.departments[0].iname_joins.loaded?                        &&
						@institution.departments[0].iname_joins[0].association(:iname).loaded? &&
						@institution.departments[0].majors.loaded?                             &&
						@institution.departments[0].majors[0].iname_joins.loaded?              &&
						@institution.departments[0].majors[0].iname_joins[0].association(:iname).loaded? )

	#test class method: get_branch with visible option
		@institution=Institution.get_branch(visible: true)[0]
		assert (@institution.departments.loaded?                                       &&
						@institution.departments[0].iname_joins.loaded?                        &&
						@institution.departments[0].iname_joins[0].association(:iname).loaded? &&
						@institution.departments[0].majors.loaded?                             &&
						@institution.departments[0].majors[0].iname_joins.loaded?              &&
						@institution.departments[0].majors[0].iname_joins[0].association(:iname).loaded? )
		@institution=Institution.get_branch[0]
		assert (@institution.departments.loaded?                                       &&
						@institution.departments[0].iname_joins.loaded?                        &&
						@institution.departments[0].iname_joins[0].association(:iname).loaded? &&
						@institution.departments[0].majors.loaded?                             &&
						@institution.departments[0].majors[0].iname_joins.loaded?              &&
						@institution.departments[0].majors[0].iname_joins[0].association(:iname).loaded? )

	end

end