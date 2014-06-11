class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @record = record
  end

  def index?
    user.admin?
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    user.admin?
  end

  def new?
    create?
  end

  def profile?
    update_profile?
  end

  def update_profile?
    user == record
  end

  def update?
    user.admin?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(:id => user.id)
      end
    end
  end
end

