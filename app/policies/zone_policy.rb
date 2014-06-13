class ZonePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope
      else
        scope.where(id: user.zone_ids)
      end
    end
  end
end
