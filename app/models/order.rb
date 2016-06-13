class Order < ActiveRecord::Base
  @@event_colors = %w(#7bd148 #5484ed #a4bdfc #46d6db #7ae7bf #51b749 #fbd75b #ffb878 #ff887c #dc2127 #dbadff #e1e1e1)

  #
  # Associations
  #
  belongs_to :workshop

  has_one :booking, dependent: :destroy, inverse_of: :order, autosave: true
  belongs_to :client, autosave: true
  belongs_to :car, autosave: true

  has_many :order_services, dependent: :destroy, inverse_of: :order
  has_many :services, :through => :order_services

  #
  # Form handling
  #
  accepts_nested_attributes_for :booking, update_only: true
  accepts_nested_attributes_for :car, update_only: true
  accepts_nested_attributes_for :client, update_only: true
  accepts_nested_attributes_for :order_services, :allow_destroy => true, :reject_if => lambda { |a| a[:service_id].blank? }

  #
  # Validations
  #
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :color, presence: true
  validates :workshop, presence: true
  validates :car, presence: true
  validates :client, presence: true
  validate :end_start_valid_range!
  validates_inclusion_of :color, in: @@event_colors

  #
  # Scopes
  #
  scope :in_range, -> (from, to) { joins(:booking).where('(bookings.start_date <= :up) and (:lo <= bookings.end_date)',
                                         lo: from.beginning_of_day.to_formatted_s(:db),
                                         up: to.end_of_day.to_formatted_s(:db)) }
  scope :in_workshop, -> (ws) { where(workshop_id: ws.id) }

  #
  # Hooks
  #
  after_initialize :init!

  # Select all events occurring in a range
  #
  # +workshop+:: Workshop of interest
  # +from+:: Beginning of the selection
  # +end+:: End of the selection
  #
  # Both ends are included in the range
  def self.range(workshop, from, to)
    Order.in_range(from, to).in_workshop(workshop)
  end

  def self.event_colors
    @@event_colors
  end

  private
  def init!
    self.color ||= Booking.event_colors[0]
  end

  def end_start_valid_range!
    if end_date and start_date and (end_date < start_date)
      errors.add(:end_date, :date_range_invalid)
    end
  end
end
