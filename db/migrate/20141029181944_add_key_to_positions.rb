class AddKeyToPositions < ActiveRecord::Migration
  def change
  	add_column :positions, :key, :string
  	add_index :positions, [:key]
  end
end
