class WorkshopPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @workshop = model
  end

  def index?
    is_user_workshop?
  end

  def new?
    is_user_workshop?
  end

  def show?
    is_user_workshop?
  end

  def create?
    is_user_workshop?
  end

  def update?
    is_user_workshop?
  end

  def destroy?
    is_user_workshop?
  end

  def is_user_workshop?
    (@current_user.workshop == @workshop) ||
        (@current_user.impersonation == @workshop) ||
        @current_user.admin?
  end
end