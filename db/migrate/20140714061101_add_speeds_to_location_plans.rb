class AddSpeedsToLocationPlans < ActiveRecord::Migration
  def change
    add_column :location_plans, :normal, :string, array: true, null: false, default: []
    add_column :location_plans, :max, :string, array: true, null: false, default: []
  end
end
