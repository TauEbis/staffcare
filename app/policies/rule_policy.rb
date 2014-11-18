class RulePolicy < ApplicationPolicy

  def index?
    if record.first.grade.nil?
      user.admin?
    else
      Pundit.policy!(user, record.first.grade).update?
    end
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
