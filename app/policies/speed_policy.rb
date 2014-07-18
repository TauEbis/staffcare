class SpeedPolicy < ApplicationPolicy

  def destroy?
    user.admin?
  end
end
