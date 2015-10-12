class AddLangReminderWithOptions < ActiveRecord::Migration
  def change
  	add_column :users, :language, :string
  	add_column :users, :reminder, :boolean, default: true
  	add_column :users, :every,    :integer, default: 1
  	add_column :users, :from,     :integer, default: 8
  	add_column :users, :to,       :integer, default: 22
  end
end
