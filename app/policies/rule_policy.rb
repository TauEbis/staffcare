class RulePolicy < ApplicationPolicy

  def index?
    if record.first.grade.nil?
      user.admin?
    else
      Pundit.policy!(user, record.first.grade).update?
    end
  end

  def edit?
    update?
  end

  def update?
    if record.grade.nil?
      user.admin?
    else
      Pundit.policy!(user, record.grade).update?
    end
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
