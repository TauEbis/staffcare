class RemoveMdrateFromSchedules < ActiveRecord::Migration
  def change
    remove_column :schedules, 'md_rate', :decimal
  end
end
