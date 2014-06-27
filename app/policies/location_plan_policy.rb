class LocationPlanPolicy < ApplicationPolicy

  def approve?
    user.admin? || user.location_ids.include?(record.location_id)
  end

  def hourly?
    show?
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
