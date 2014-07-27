class AddIndexToHeatmaps < ActiveRecord::Migration
  def change
    add_index :heatmaps, :uid
  end
end
