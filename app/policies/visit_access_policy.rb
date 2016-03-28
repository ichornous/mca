class VisitAccessPolicy
  attr_reader :principal
  attr_reader :workshop_policy

  def initialize(workshop_policy, principal)
    @workshop_policy = workshop_policy
    @order_policy = OrderAccessPolicy.new(workshop_policy, principal)
    @principal = principal
  end

  # Parent resource
  def index?(workshop)
    @workshop_policy.show?(workshop) or @principal.workshop == event.workshop
  end

  def create?(workshop)
    @workshop_policy.update?(workshop) or @principal.workshop == workshop
  end

  # Check whether the security principal has permissions to view `event`
  def show?(event)
    @order_policy.show?(event.order)
  end

  def update?(event)
    @order_policy.update?(event.order)
  end

  def delete?(event)
    @order_policy.update?(event.order)
  end

  private
  # Check whether the principal is in the admin role
  def admin?
    @principal.try(:admin?)
  end
end