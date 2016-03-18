class Workshop < ActiveRecord::Base
  has_many :visits
  has_many :users
end
