class User < ActiveRecord::Base
  belongs_to :workshop
  enum role: [:admin, :director, :manager, :sales]
  # Access policy:
  #  - admin can review and edit everything
  #  - director can review and edit everything
  #  - manager can review and edit all of the events related to his workshop
  #  - sales can only review events in his workshop
  after_initialize :set_default_role, :if => :new_record?
  validates :username, presence: true

  def set_default_role
    self.role ||= :sales
  end

  def self.generate_password
    [*('A'..'Z')].sample(8).join
  end

  # Include default devise modules. Others available are:
  # :ldap_authenticatable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
end
