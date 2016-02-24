class Workshop < ActiveRecord::Base
  has_many :visits
  has_many :users
  has_many :clients
  has_many :cars
  has_many :orders
end
