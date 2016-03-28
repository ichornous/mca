class Order < ActiveRecord::Base
  belongs_to :workshop
  belongs_to :client
  belongs_to :car
  has_many :services, :through => :event_services
end
