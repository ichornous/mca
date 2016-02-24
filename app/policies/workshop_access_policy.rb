class WorkshopAccessPolicy
  attr_reader :principal
  attr_reader :directory_policy
  def initialize(directory_policy, principal)
    @directory_policy = directory_policy
    @principal = principal
  end

  # Parent resource
  def index?(directory)
    @directory_policy.show?(directory)
  end

  def create?(directory)
    @directory_policy.update?(directory)
  end

  # Check whether the security principal has permissions to list resources in `workshop`
  def show?(workshop)
    elevated_access?(workshop)
  end

  def update?(workshop)
    elevated_access?(workshop)
  end

  def delete?(workshop)
    @directory_policy.update?(nil)
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
    return true if admin?
    return false if workshop.nil?
    return true if (@principal.manager? or @principal.director?) and @principal.workshop == workshop
    return false
  end
end