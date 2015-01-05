class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.date :date, null: false
      t.json :volumes, default: {}, null: false
      t.integer :granularity, default: 15, null: false
      t.integer :dow, null: false
      t.references :location, index: true
      t.references :report_server_ingest, index: true

      t.timestamps
    end
  end
end
