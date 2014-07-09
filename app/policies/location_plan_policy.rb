class LocationPlanPolicy < ApplicationPolicy

  def approve?
    update?
  end

  def update?
    user.admin? ||
    ( user.location_ids.include?(record.location_id) && record.schedule.active? )
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
