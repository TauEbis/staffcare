class TodoPresenter < Struct.new(:user)

  TODO_STATES = {
    'manager' => LocationPlan.approval_states[:pending],
    'rm'      => LocationPlan.approval_states[:manager_approved],
    'admin'   => LocationPlan.approval_states[:rm_approved]
  }

  MINION_ROLES = {'rm' => User.roles[:manager], 'admin' => User.roles[:rm]}

  def active_schedule_ids
    @_active_schedule_ids ||= Schedule.active.has_deadlines.pluck(:id)
  end

  # MY todo location_plans
  def location_plans
    LocationPlanPolicy.new(user, LocationPlan.new).scope.
      where(schedule_id: active_schedule_ids).
      where(approval_state: TODO_STATES[user.role]).
      includes(:schedule, :location).
      ordered
  end

  def minions
    user_ids = Membership.where(location_id: user.location_ids).select(:user_id).distinct

    m = User.
        where(id: user_ids).
        where.not(id: user.id).
        where(role: MINION_ROLES[user.role])

    m.map do |user|
      lp = TodoPresenter.new(user).location_plans
      {
        user: user,
        todos: lp,
        todo_count: lp.count
      }
    end
  end
end
