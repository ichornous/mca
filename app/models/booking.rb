class Booking < ActiveRecord::Base
  @@event_colors = %w(#7bd148 #5484ed #a4bdfc #46d6db #7ae7bf #51b749 #fbd75b #ffb878 #ff887c #dc2127 #dbadff #e1e1e1)

  belongs_to :order, inverse_of: :booking

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :color, presence: true
  validates :order, presence: true
  validates_inclusion_of :color, in: @@event_colors

  validate :end_start_valid_range!
  validates_uniqueness_of :order_id, message: 'can not have more than one booking'

  after_initialize :init!

  scope :in_range, -> (from, to) { where('(start_date <= :up) and (:lo <= end_date)',
                                        lo: from.beginning_of_day.to_formatted_s(:db),
                                        up: to.end_of_day.to_formatted_s(:db)) }
  scope :in_workshop, -> (ws) { joins(:order).where(orders: { workshop_id: ws.id }) }

  def self.event_colors
    @@event_colors
  end

  # Select all events occurring in a range
  #
  # +workshop+:: Workshop of interest
  # +from+:: Beginning of the selection
  # +end+:: End of the selection
  #
  # Both ends are excluded from the range
  def self.range(workshop, from, to)
    Booking.in_range(from, to).in_workshop(workshop)
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
