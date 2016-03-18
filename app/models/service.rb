class Service < ActiveRecord::Base
  has_many :order_services
  has_many :events, :through => :event_services
end
