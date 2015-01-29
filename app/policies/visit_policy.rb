class VisitPolicy < ApplicationPolicy

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope
      else
        scope
      end
    end
  end
end
