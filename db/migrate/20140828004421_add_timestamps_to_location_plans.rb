class AddTimestampsToLocationPlans < ActiveRecord::Migration
  def change
  	add_column :location_plans, :created_at, :datetime, default: Time.now, null: false
    add_column :location_plans, :updated_at, :datetime, default: Time.now, null: false
  end
end
