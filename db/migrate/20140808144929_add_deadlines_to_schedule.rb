class AddDeadlinesToSchedule < ActiveRecord::Migration
  def change
    add_column :schedules, :manager_deadline, :date
    add_column :schedules, :gm_deadline, :date
    add_column :schedules, :sync_deadline, :date
  end
end
