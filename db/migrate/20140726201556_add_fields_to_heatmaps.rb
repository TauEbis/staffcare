class AddFieldsToHeatmaps < ActiveRecord::Migration
  def change
    add_column :heatmaps, :name, :string
    add_column :heatmaps, :days, :text
  end
end
