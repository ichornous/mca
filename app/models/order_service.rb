class OrderService < ActiveRecord::Base
  belongs_to :visit
  belongs_to :service
end
