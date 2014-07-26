class AddReportServerIngestIdToIngestRecords < ActiveRecord::Migration
  def change
    add_reference :ingest_records, :report_server_ingest, index: true
  end
end
