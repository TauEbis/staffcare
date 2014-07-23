class AddWiwIdToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :wiw_id, :integer
  end
end
