class AddTurboToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, 'penalty_turbo', :decimal, precision: 8, scale: 4, null: false
  end
end
