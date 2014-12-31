class AddReportServerIngestIdToHeatmap < ActiveRecord::Migration
  def change
    add_column :heatmaps, :report_server_ingest_id, :integer
    add_index :heatmaps, :report_server_ingest_id
  end
end
