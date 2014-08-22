class AddTimestampsToHeatmaps < ActiveRecord::Migration
  def change
    add_column :heatmaps, :created_at, :datetime
    add_column :heatmaps, :updated_at, :datetime
  end
end
