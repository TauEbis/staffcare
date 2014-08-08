class TodoPresenter < Struct.new(:user)

  TODO_STATES = {'manager' => :pending, 'gm' => :manager_approved, 'admin' => :gm_approved}

  def active_schedule_ids
    @_active_schedule_ids ||= Schedule.active.pluck(:id)
  end

  def location_plans
    LocationPlanPolicy.new(user, LocationPlan.new).scope.
      where(schedule_id: active_schedule_ids).
      where(approval_state: LocationPlan.approval_states[TODO_STATES[user.role]]).
      includes(:schedule).
      ordered
  end

  def to_a
    location_plans.to_a
  end
end
