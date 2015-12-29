class Visit < ActiveRecord::Base
  has_many :contacts, dependent: :destroy
  validates :name, presence: true, length: {minimum: 1}
end
