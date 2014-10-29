class PositionPolicy < ApplicationPolicy

  def index?
    user.admin?
  end

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
