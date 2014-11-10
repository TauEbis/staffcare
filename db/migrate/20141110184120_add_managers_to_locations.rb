class AddManagersToLocations < ActiveRecord::Migration
  def change
  	add_column :locations, :managers, :integer, null: false, default: 1
  	add_column :locations, :assistant_managers, :integer, null: false, default: 1
  end
end
