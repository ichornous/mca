class Workshop < ActiveRecord::Base
  has_many :users
  has_many :clients
  has_many :cars
  has_many :orders
  has_many :inquiries
end
