class OrderService < ActiveRecord::Base
  belongs_to :order
  belongs_to :service
end
