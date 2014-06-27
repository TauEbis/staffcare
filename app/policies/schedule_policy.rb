class SchedulePolicy < ApplicationPolicy
  def show?
    user.admin? || !record.draft?
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
