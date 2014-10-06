class AddTimestampsToLocationPlans < ActiveRecord::Migration
  def change
  	add_column :location_plans, :created_at, :datetime, default: '2014-10-01 00:00:00', null: false
    add_column :location_plans, :updated_at, :datetime, default: '2014-10-01 00:00:00', null: false
  end
end
