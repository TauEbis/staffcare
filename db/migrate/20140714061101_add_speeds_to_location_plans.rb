class AddSpeedsToLocationPlans < ActiveRecord::Migration
  def change
    add_column :location_plans, :normal, :decimal, precision: 8, scale: 4, array: true, null: false, default: []
    add_column :location_plans, :max, :decimal, precision: 8, scale: 4, array: true, null: false, default: []
  end
end
