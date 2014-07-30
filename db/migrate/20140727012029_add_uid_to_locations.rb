class AddUidToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :uid, :string
  end
end
