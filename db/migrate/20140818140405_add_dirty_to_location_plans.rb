class AddDirtyToLocationPlans < ActiveRecord::Migration
  def change
    add_column :location_plans, :wiw_sync, :integer, default: 0, null: false
  end
end
