class ScheduleDestroyer

  def initialize(schedule)
    @schedule = schedule
  end

  def destroy
    schedule_id = @schedule.id

    visit_projection_ids = VisitProjection.where(schedule_id: schedule_id).pluck(:id)
    location_plan_ids = LocationPlan.where(schedule_id: schedule_id).pluck(:id)
    grade_ids = Grade.where(location_plan_id: location_plan_ids).pluck(:id)
    shift_ids = Shift.where(grade_id: grade_ids).pluck(:id)
    push_ids = Push.where(location_plan_id: location_plan_ids).pluck(:id)

    success = false

    ActiveRecord::Base.transaction do
      Shift.where(id: shift_ids).delete_all
      Grade.where(id: grade_ids).delete_all
      Push.where(id: push_ids).delete_all
      LocationPlan.where(id: location_plan_ids).delete_all
      VisitProjection.where(id: visit_projection_ids).delete_all
      @schedule.delete
      success =  true
    end

    success
  end
end
