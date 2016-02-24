class DirectoryAccessPolicy
  attr_reader :principal
  def initialize(principal)
    @principal = principal
  end

  # Check whether the security principal has permissions to list resources in `directory`
  def show?(directory)
    admin?
  end

  def update?(directory)
    admin?
  end

  def delete?(directory)
    admin?
  end

  private
  # Check whether the principal is in the admin role
  def admin?
    @principal.try(:admin?)
  end
end