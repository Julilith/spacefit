class DeleteUserApprankTable < ActiveRecord::Migration
  def change
  	drop_table :user_appranks
  end
end
