class RemovePoliciesFromLocationPlan < ActiveRecord::Migration
  def change
  	remove_index :location_plans, :life_cycle_id

    remove_column :location_plans, :life_cycle_id
    remove_column :location_plans, :scribe_policy
    remove_column :location_plans, :pcr_policy
    remove_column :location_plans, :ma_policy
    remove_column :location_plans, :xray_policy
    remove_column :location_plans, :am_policy
  end
end
