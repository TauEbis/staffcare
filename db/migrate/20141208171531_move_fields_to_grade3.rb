# We assume all the data has been filled in from MoveFieldsToGrade2
class MoveFieldsToGrade3 < ActiveRecord::Migration
  def change
    change_column_null :grades, :location_id, false
    change_column_null :grades, :schedule_id, false
    change_column_null :grades, :visit_projection_id, false

    [:visit_projection_id, :visits, :max_mds, :rooms, :min_openers,
    :min_closers, :open_times, :close_times, :optimizer_job_id, :optimizer_state, :normal, :max].each do |key|
      remove_column :location_plans, key
    end
  end
end
