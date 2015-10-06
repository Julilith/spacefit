class Medias < ActiveRecord::Migration
  def change
		create_table :medias do |t|
			t.string   :type
			t.string   :location
			t.string   :position
			t.string   :link
		end
		add_index :medias, [:type, :location, :position]
  end
end
