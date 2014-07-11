class LocationPlanPolicy < ApplicationPolicy
  def state_downgrade?
    case record.approval_state
      when 'manager_approved'
        state_pending?
      when 'gm_approved'
        state_manager_approved?
      else
        false
    end
  end

  def state_upgrade?
    case record.approval_state
      when 'pending'
        state_manager_approved?
      when 'manager_approved'
        state_gm_approved?
      else
        false
    end
  end

  # Can transition to pending?
  def state_pending?
    record.manager_approved?
  end

  def state_manager_approved?
    record.pending? ||  # Moving up is allowed for all
      (record.gm_approved? && ['admin', 'gm'].include?(user.role))  # Managers can't move down out of gm_approved state
  end

  def state_gm_approved?
    record.manager_approved? && ['admin', 'gm'].include?(user.role)
  end

  def change_state?
    update?
  end

  def update?
    record.schedule.active? &&
    ( user.admin? ||
      (user.location_ids.include?(record.location_id) && (state_upgrade? || state_downgrade?))
    )
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope
      else
        scope.where(location_id: user.location_ids)
      end
    end
  end
end
