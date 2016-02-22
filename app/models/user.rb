class User < ActiveRecord::Base
  belongs_to :workshop
  enum role: [:admin, :director, :manager, :sales]
  # Access policy:
  #  - admin can review and edit everything
  #  - director can review and edit everything
  #  - manager can review and edit all of the events related to his workshop
  #  - sales can only review events in his workshop
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :sales
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
