class AddPositionReferenceToShifts < ActiveRecord::Migration
  def change
    remove_index :shifts, [:grade_id, :position, :starts_at]

    remove_column :shifts, :position
    add_reference :shifts, :position, index: true

    add_index :shifts, [:grade_id, :position_id, :starts_at]
  end
end
