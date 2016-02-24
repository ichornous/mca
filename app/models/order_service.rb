class OrderService < ActiveRecord::Base
  after_initialize :default_values
  belongs_to :order
  belongs_to :service

  private
  def default_values
    self.amount ||= 1.0
  end
end
