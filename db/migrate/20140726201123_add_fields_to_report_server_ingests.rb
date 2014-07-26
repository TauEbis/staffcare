class AddFieldsToReportServerIngests < ActiveRecord::Migration
  def change
    add_column :report_server_ingests, :start_date, :date
    add_column :report_server_ingests, :end_date, :date
    add_column :report_server_ingests, :locations, :string
    add_column :report_server_ingests, :heatmaps, :string
    add_column :report_server_ingests, :totals, :string
  end
end
