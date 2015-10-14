class RenameMetiaTypeCollumnToKind < ActiveRecord::Migration
	def change
		remove_index :medias, name: :index_medias_on_type_and_location_and_position
		rename_column :medias, :type, :wo_type
		add_index :medias, [:wo_type, :location, :position]
	end
end
