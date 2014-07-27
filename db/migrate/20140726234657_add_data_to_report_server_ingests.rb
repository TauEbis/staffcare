class AddDataToReportServerIngests < ActiveRecord::Migration
  def change
    add_column :report_server_ingests, :data, :text
  end
end
