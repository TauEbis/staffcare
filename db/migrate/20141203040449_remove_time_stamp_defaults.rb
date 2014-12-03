class RemoveTimeStampDefaults < ActiveRecord::Migration
  def up
  	change_column_default :heatmaps, :created_at, nil
    change_column_default :heatmaps, :updated_at, nil
    change_column_default :location_plans, :created_at, nil
    change_column_default :location_plans, :updated_at, nil
    change_column_default :patient_volume_forecasts, :created_at, nil
    change_column_default :patient_volume_forecasts, :updated_at, nil
  end

  def down
  	change_column_default :heatmaps, :created_at, '2014-10-01 00:00:00'
    change_column_default :heatmaps, :updated_at, '2014-10-01 00:00:00'
    change_column_default :location_plans, :created_at, '2014-10-01 00:00:00'
    change_column_default :location_plans, :updated_at, '2014-10-01 00:00:00'
    change_column_default :patient_volume_forecasts, :created_at, '2014-10-01 00:00:00'
    change_column_default :patient_volume_forecasts, :updated_at, '2014-10-01 00:00:00'
  end
end
