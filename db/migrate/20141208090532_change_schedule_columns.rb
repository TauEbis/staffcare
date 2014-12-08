class ChangeScheduleColumns < ActiveRecord::Migration
  def change
  	rename_column :schedules, :penalty_slack, :md_hourly
  	remove_column :schedules, :oren_shift, :boolean, null: false, default: false
  end
end
