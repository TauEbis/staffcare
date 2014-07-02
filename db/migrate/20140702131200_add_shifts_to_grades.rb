class AddShiftsToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :shifts, :json, null: false, default: {}
  end
end
