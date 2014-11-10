class RenameGmDeadlinetoRmDeadlineOnSchedules < ActiveRecord::Migration
  def change
  	rename_column :schedules, :gm_deadline, :rm_deadline
  end
end
