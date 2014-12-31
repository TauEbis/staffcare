class RenameLocationsReportServerId < ActiveRecord::Migration
  def change
    rename_column :locations, :report_server_id, :upload_id
  end
end
