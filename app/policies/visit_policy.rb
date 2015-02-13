class VisitPolicy < ApplicationPolicy

  def index?
    user.admin?
  end

  def am_pm?
    index?
  end

end
