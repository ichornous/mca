class Order < ActiveRecord::Base
  belongs_to :workshop
  belongs_to :client
  belongs_to :car
  has_many :order_services
  has_many :services, :through => :order_services

  accepts_nested_attributes_for :order_services, :allow_destroy => true # :reject_if => lambda { |a| a[:service_id].blank? },
end
