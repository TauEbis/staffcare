class AddHourlyRateToPositions < ActiveRecord::Migration
  def change
  	add_column :positions, :hourly_rate, :integer
  end
end
