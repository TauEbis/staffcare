class SchedulePolicy < ApplicationPolicy

  def index?
    user.admin? || (!user.locations.empty? && !record.empty?)
  end

  def show?
    user.admin? || (!record.draft? && !user.locations.empty?)
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
