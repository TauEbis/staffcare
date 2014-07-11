class RenameInputProjections < ActiveRecord::Migration
  def change
     rename_table :input_projections, :patient_volume_forecasts
  end
end
