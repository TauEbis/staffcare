class HeatmapLocationAssociation < ActiveRecord::Migration
  def change
    remove_index :heatmaps, :uid

    remove_column :heatmaps, :uid, :string
    add_reference :heatmaps, :location, index: true

  end
end
