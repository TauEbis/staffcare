class CreateShifts < ActiveRecord::Migration
  def change
    create_table :shifts do |t|
      t.references :grade, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false

      t.string :wiw_id

      t.timestamps
    end

    add_index :shifts, [:grade_id, :starts_at]

    remove_column :grades, :shifts
  end
end
