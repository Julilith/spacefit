class UserBasic < ActiveRecord::Base
	belongs_to :user, autosave: true
end