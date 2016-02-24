class OrderAccessPolicy
  attr_reader :principal
  attr_reader :workshop_policy

  def initialize(workshop_policy, principal)
    @workshop_policy = workshop_policy
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
  def show?(order)
    @workshop_policy.show?(order.workshop) or @principal.workshop == order.workshop
  end

  def update?(order)
    @workshop_policy.update?(order.workshop) or @principal.workshop == order.workshop
  end

  def delete?(order)
    @workshop_policy.update?(order.workshop)
  end

  private
  # Check whether the principal is in the admin role
  def admin?
    @principal.try(:admin?)
  end
end