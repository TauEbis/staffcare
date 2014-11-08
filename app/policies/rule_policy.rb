class RulePolicy < ApplicationPolicy

  def index?
    user.admin?
  end

  def update?
    user.admin?
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope
      else
        Rule.none
      end
    end
  end

end
