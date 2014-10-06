class AddOptimizerToLocationPlans < ActiveRecord::Migration
  def change
    add_column :location_plans, :optimizer_state, :integer, default: 0, null: false
    add_column :location_plans, :optimizer_job_id, :string
  end
end
