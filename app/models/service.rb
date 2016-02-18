class Service < ActiveRecord::Base
  has_many :event_services
  has_many :events, :through => :event_services
end
