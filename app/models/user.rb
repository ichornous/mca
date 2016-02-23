class User < ActiveRecord::Base
  belongs_to :workshop
  enum role: [:admin, :director, :manager, :sales]
  # Access policy:
  #  - admin can review and edit everything
  #  - director can review and edit everything
  #  - manager can review and edit all of the events related to his workshop
  #  - sales can only review events in his workshop
  after_initialize :set_default_role, :if => :new_record?
  validates :first_name, presence: true
  validates :last_name, presence: true

  def set_default_role
    self.role ||= :sales
  end

  # Include default devise modules. Others available are:
  # :ldap_authenticatable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
end
