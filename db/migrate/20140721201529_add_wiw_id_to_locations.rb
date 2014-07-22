class AddWiwIdToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :wiw_id, :string
  end
end
