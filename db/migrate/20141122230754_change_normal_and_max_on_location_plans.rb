class ChangeNormalAndMaxOnLocationPlans < ActiveRecord::Migration
  def change
  	remove_column :location_plans, :normal, :string, array: true, null: false, default: []
    remove_column :location_plans, :max, :string, array: true, null: false, default: []
    add_column :location_plans, :normal, :decimal, precision: 8, scale: 4, array: true, null: false, default: []
    add_column :location_plans, :max, :decimal, precision: 8, scale: 4, array: true, null: false, default: []
  end
end
