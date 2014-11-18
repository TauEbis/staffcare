class CommentPolicy < ApplicationPolicy

  def create?
    true
  end

  def update?
    false
  end

  def destroy?
    false
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end
