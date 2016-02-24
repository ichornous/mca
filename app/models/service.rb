class Service < ActiveRecord::Base
  has_many :order_services
  has_many :orders, :through => :order_services
end
