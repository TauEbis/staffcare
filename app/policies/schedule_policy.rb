class SchedulePolicy < ApplicationPolicy

  def index?
    user.admin? || (!user.locations.empty? && !record.empty?)
  end

  def show?
    user.admin? || (!record.draft? && !user.locations.empty?)
  end

  def push?
    user.admin?
  end

  def state_draft?
    user.admin? && record.draft?
  end

  def state_active?
    record.active?
  end

  def state_locked?
    user.admin? && record.locked?
  end

  def request_approvals?
    user.admin? && (record.draft? || record.active?)
  end


  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope
      else
        scope.not_draft
      end
    end
  end

end
