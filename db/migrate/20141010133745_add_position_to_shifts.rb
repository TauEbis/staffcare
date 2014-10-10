class AddPositionToShifts < ActiveRecord::Migration
  def change
    add_column :shifts, :position, :integer, default: 0, null: false

    add_index :shifts, [:grade_id, :position, :starts_at]
    add_index :shifts, [:wiw_id]
  end
end
