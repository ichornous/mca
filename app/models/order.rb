class Order < ActiveRecord::Base
  belongs_to :workshop

  has_one :booking, dependent: :destroy, inverse_of: :order, autosave: true
  belongs_to :client, autosave: true
  belongs_to :car, autosave: true

  has_many :order_services, dependent: :destroy, inverse_of: :order
  has_many :services, :through => :order_services

  validates :workshop, presence: true
  validates :car, presence: true
  validates :client, presence: true

  accepts_nested_attributes_for :booking, update_only: true
  accepts_nested_attributes_for :car, update_only: true
  accepts_nested_attributes_for :client, update_only: true

  accepts_nested_attributes_for :order_services, :allow_destroy => true, :reject_if => lambda { |a| a[:service_id].blank? }

  scope :in_range, -> (from, to) { joins(:booking).where('(bookings.start_date <= :up) and (:lo <= bookings.end_date)',
                                         lo: from.beginning_of_day.to_formatted_s(:db),
                                         up: to.end_of_day.to_formatted_s(:db)) }
  scope :in_workshop, -> (ws) { where(workshop_id: ws.id) }

  # Select all events occurring in a range
  #
  # +workshop+:: Workshop of interest
  # +from+:: Beginning of the selection
  # +end+:: End of the selection
  #
  # Both ends are excluded from the range
  def self.range(workshop, from, to)
    Order.in_range(from, to).in_workshop(workshop)
  end
end
