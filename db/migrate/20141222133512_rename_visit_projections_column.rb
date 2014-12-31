class RenameVisitProjectionsColumn < ActiveRecord::Migration
  def change
    rename_column :visit_projections, :heat_maps, :heatmap
  end
end
