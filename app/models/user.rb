class User < ActiveRecord::Base
  belongs_to :workshop
  enum role: {admin: 0, director: 1, manager: 2, sales: 3}
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

  def set_default_role
    self.role ||= :sales
  end

  def self.compare_roles(a, b)
    User.roles[a] >= User.roles[b]
  end
  # Include default devise modules. Others available are:
  # :ldap_authenticatable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
end
