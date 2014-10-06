class AddTimestampsToPatientVolumeForecasts < ActiveRecord::Migration
  def change
  	add_column :patient_volume_forecasts, :created_at, :datetime, default: '2014-10-01 00:00:00', null: false
    add_column :patient_volume_forecasts, :updated_at, :datetime, default: '2014-10-01 00:00:00', null: false
  end
end
