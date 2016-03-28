class Order < ActiveRecord::Base
  belongs_to :workshop
  belongs_to :client
  belongs_to :car
  has_many :order_services
  has_many :services, :through => :order_services
end
