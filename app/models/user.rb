class User < ActiveRecord::Base
  belongs_to :workshop, :class_name => "Workshop"
  belongs_to :impersonation, :class_name => "Workshop"

  enum role: {admin: 0, manager: 1, sales: 2}
  # Access policies:
  #  - admin can review and edit everything
  #  - director can review and edit everything
  #  - manager can review and edit all of the events related to his workshop
  #  - sales can only review events in his workshop
  after_initialize :set_default_role, :if => :new_record?

  validates :username, presence: true

  def password_required?
    super if confirmed?
  end

  def password_match?
    self.errors[:password] << "can't be blank" if password.blank?
    self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
    self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
    password == password_confirmation && !password.blank?
  end

  # Roles
  def set_default_role
    self.role ||= :sales
  end

  # Check whether the user has permissions to assign a given `role` to another instance of +User+
  # `role` is a symbol from the +role+ enumeration
  # @return [true, false]
  def can_assign_role?(role)
    admin? or User.compare_roles(role, self.role)
  end

  def self.compare_roles(a, b)
    User.roles[a] >= User.roles[b]
  end

  # Impersonation
  def current_workshop
    if is_impersonated?
      self.impersonation
    else
      self.workshop
    end
  end

  def is_impersonated?
    not(self.impersonation.nil?)
  end

  def impersonate(ws)
    return false unless ws.nil? or admin?
    self.impersonation = ws
    true
  end

  # Include default devise modules. Others available are:
  # :ldap_authenticatable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
end
