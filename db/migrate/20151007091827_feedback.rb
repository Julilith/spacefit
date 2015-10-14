class Feedback < ActiveRecord::Migration
  def change
  	create_table :feedbacks do |t|
  		t.integer  :user_id
  		t.text     :text
  	end
  	add_index :feedbacks, :user_id
  end
end
