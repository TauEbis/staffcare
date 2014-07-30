class GradePolicy < ApplicationPolicy

  def create?
    Pundit.policy!(user, record.location_plan).update?
  end

  def hourly?
    show?
  end

  def highcharts?
    show?
  end

  def update?
    case record.source
      when 'manual'
        Pundit.policy!(user, record.location_plan).update? && record.user == user
      else
        false
    end
  end

  def destroy?
    update?
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope
      else
        scope#.where(location_id: user.location_ids)
      end
    end
  end
end
