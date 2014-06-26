class LocationPlanPolicy < ApplicationPolicy
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
