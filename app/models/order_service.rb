class OrderService < ActiveRecord::Base
  after_initialize :default_values
  belongs_to :order, inverse_of: :order_services
  belongs_to :service

  #validates :order
  validates :service, presence: true

  private
  def default_values
    self.amount ||= 1.0
  end
end
