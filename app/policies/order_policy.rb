class OrderPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @model = model
  end

  def index?
    true
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

  private
  def is_user_workshop?
    @current_user.admin? ||
        (@current_user.workshop == @model.workshop) ||
        (@current_user.impersonation == @model.workshop)
  end
end