class AddVolumeSourceToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :volume_source, :integer, default: 0, null: false
  end
end
