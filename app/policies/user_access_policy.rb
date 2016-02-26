class UserAccessPolicy
  attr_reader :principal
  attr_reader :workshop_policy

  def initialize(workshop_policy, principal)
    @workshop_policy = workshop_policy
    @principal = principal
  end

  # Parent resource
  def create?(workshop)
    @workshop_policy.update?(workshop)
  end

  def index?(workshop)
    @workshop_policy.show?(workshop)
  end

  # Check whether the security principal has permissions to view `user`
  # It is assumed that the user can access it's own profile
  def show?(user)
    @workshop_policy.show?(user.workshop) or @principal == user
  end

  def update?(user)
    @workshop_policy.update?(user.workshop) or @principal == user
  end

  def delete?(user)
    return false if not admin? and user.admin?
    @workshop_policy.update?(user.workshop)
  end

  def assign_role?(role)
    admin? or User.compare_roles(role, @principal.role)
  end

  private
  # Check whether the principal is in the admin role
  def admin?
    @principal.try(:admin?)
  end
end