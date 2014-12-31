class ChangeHeatmapsColumns < ActiveRecord::Migration
  def change
    remove_column :heatmaps, :name, :string
    remove_column :heatmaps, :days, :text
    add_column :heatmaps, :days, :json, default: {}, null: false
  end
end
