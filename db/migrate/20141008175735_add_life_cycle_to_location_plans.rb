class AddLifeCycleToLocationPlans < ActiveRecord::Migration
  def change
    add_column :location_plans, :life_cycle_id, :integer
    add_column :location_plans, :scribe_policy, :integer
    add_column :location_plans, :pcr_policy, :integer
    add_column :location_plans, :ma_policy, :integer
    add_column :location_plans, :xray_policy, :integer
    add_column :location_plans, :am_policy, :integer

    add_index :location_plans, :life_cycle_id
  end
end
