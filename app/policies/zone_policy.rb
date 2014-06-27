class ZonePolicy < ApplicationPolicy
  def approve?
    user.admin? || user.zone_ids.include?(record.id)
  end

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
