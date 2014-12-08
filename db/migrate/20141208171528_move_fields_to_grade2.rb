# This stuff copies the data between MoveFieldsToGrade and MoveFieldsToGrade3
class MoveFieldsToGrade2 < ActiveRecord::Migration
  def up
    LocationPlan.find_each do |lp|
      lp.grades.find_each do |g|

        [:location_id, :schedule_id, :visit_projection_id, :visits, :max_mds, :rooms, :min_openers,
         :min_closers, :open_times, :close_times, :optimizer_job_id, :optimizer_state, :normal, :max].each do |key|
          g.send "#{key}=", lp.send(key)
        end

        g.save!
      end
    end
  end

  def down

  end
end
