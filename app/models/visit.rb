class Visit < ActiveRecord::Base
  has_many :contacts
  validates :name, presence: true, length: {minimum: 1}
end
