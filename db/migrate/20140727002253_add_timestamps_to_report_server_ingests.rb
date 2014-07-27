class AddTimestampsToReportServerIngests < ActiveRecord::Migration
  def change
    add_column :report_server_ingests, :created_at, :datetime, :null => true, :default => nil
    add_column :report_server_ingests, :updated_at, :datetime, :null => true, :default => nil
  end
end
