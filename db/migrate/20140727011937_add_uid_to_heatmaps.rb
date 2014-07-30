class AddUidToHeatmaps < ActiveRecord::Migration
  def change
    add_column :heatmaps, :uid, :string
  end
end
