class ChangeReportServerIngestColumns < ActiveRecord::Migration
  def change
    remove_column :report_server_ingests, :locations, :string
    remove_column :report_server_ingests, :heatmaps, :string
    remove_column :report_server_ingests, :totals, :string
    remove_column :report_server_ingests, :data, :text
    add_column :report_server_ingests, :data, :json, default: {}, null: false
  end
end
