class AddTimestampsToPatientVolumeForecasts < ActiveRecord::Migration
  def change
  	add_column :patient_volume_forecasts, :created_at, :datetime, default: Time.now, null: false
    add_column :patient_volume_forecasts, :updated_at, :datetime, default: Time.now, null: false
  end
end
