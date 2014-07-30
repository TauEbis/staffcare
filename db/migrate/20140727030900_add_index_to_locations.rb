class AddIndexToLocations < ActiveRecord::Migration
  def change
    add_index :locations, :uid
  end
end
