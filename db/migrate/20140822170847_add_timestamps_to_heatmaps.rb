class AddTimestampsToHeatmaps < ActiveRecord::Migration
  def change
    add_column :heatmaps, :created_at, :datetime, default: '2014-10-01 00:00:00', null: false
    add_column :heatmaps, :updated_at, :datetime, default: '2014-10-01 00:00:00', null: false
  end
end
