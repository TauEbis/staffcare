class AddOptimizerStateToSchedule < ActiveRecord::Migration
  def change
    add_column :schedules, :optimizer_state, :integer, null: false, default: 0
    add_column :schedules, :optimizer_job_id, :string
  end
end
