class UserAccessPolicy
  attr_reader :principal
  def initialize(principal)
    @principal = principal
  end

  # Check whether the scurity principal has permissions to list users in `workshop`
  def list?(workshop)
    return true if workshop.nil? and admin?
    elevated_access?(workshop)
  end

  # Check whether the security principal has permissions to view `user`
  # It is assumed that the user can access it's own profile
  def show?(user)
    elevated_access?(user.workshop) or @principal == user
  end

  def update?(user)
    elevated_access?(user.workshop) or @principal == user
  end

  def assign_workshop?(workshop)
    (workshop.nil? and admin?) or elevated_access?(workshop)
  end

  def assign_role?(role)
    admin? or User.compare_roles(role, @principal.role)
  end

  def delete?(user)
    return false if admin? or not user.admin?
    elevated_access?(user.workshop)
  end

  private
  # Check whether the principal is in the admin role
  def admin?
    @principal.try(:admin?)
  end

  # Check whether the user has elevated privileges in `workshop`
  def elevated_access?(workshop)
    # Order in which rules are checks does matter
    return false if @principal.nil?
    return true if @principal.admin?
    return false if workshop.nil?
    return true if (@principal.manager? or @principal.director?) and @principal.workshop == workshop
    return false
  end
end