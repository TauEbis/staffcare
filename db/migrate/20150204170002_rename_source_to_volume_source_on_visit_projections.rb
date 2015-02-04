class RenameSourceToVolumeSourceOnVisitProjections < ActiveRecord::Migration
  def change
    remove_column :visit_projections, :source, :string
    add_column :visit_projections, :volume_source, :integer, default: 0, null: false
  end
end
