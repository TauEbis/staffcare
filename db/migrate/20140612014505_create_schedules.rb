class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.date :starts_on
      t.integer :state

      t.timestamps
    end
  end
end
