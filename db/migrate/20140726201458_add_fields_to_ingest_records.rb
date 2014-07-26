class AddFieldsToIngestRecords < ActiveRecord::Migration
  def change
    add_column :ingest_records, :name, :string
    add_column :ingest_records, :days, :string
    add_column :ingest_records, :total_vists, :float
  end
end
