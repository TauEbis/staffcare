class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.date :starts_on
      t.integer :state, null: false, default: 0

      t.timestamps
    end
  end
end
