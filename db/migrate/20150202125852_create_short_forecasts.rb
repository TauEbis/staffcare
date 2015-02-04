class CreateShortForecasts < ActiveRecord::Migration
  def change
    create_table :short_forecasts do |t|
      t.json :visits, default: {}, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :lookback_window, default: 10, null: false
      t.integer :forecast_window, default: 12, null: false
      t.json :lookback_data, default: {}
      t.json :forecaster_opts, default: {}

      t.references :location, index: true
      t.references :report_server_ingest, index: true

      t.timestamps
    end
  end
end
