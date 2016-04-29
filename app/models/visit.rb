class Visit < ActiveRecord::Base
  @@event_colors = %w(#7bd148 #5484ed #a4bdfc #46d6db #7ae7bf #51b749 #fbd75b #ffb878 #ff887c #dc2127 #dbadff #e1e1e1)

  belongs_to :order
  belongs_to :workshop

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :color, presence: true
  validates :workshop, presence: true
  validates_inclusion_of :color, in: @@event_colors

  validate :workshop_consistent!
  validate :end_start_valid_range!
  accepts_nested_attributes_for :order

  after_initialize :init!

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
    workshop.visits.
        where('(start_date <= :up) and (:lo <= end_date)',
              lo: from.beginning_of_day.to_formatted_s(:db),
              up: to.end_of_day.to_formatted_s(:db))
  end

  private
  def init!
    self.color ||= Visit.event_colors[0]
  end

  # Ensure that the order's workshop matches the visit's one
  def workshop_consistent!
    return if order.nil?
    if order.workshop != workshop
      errors.add(:workshop, :inconsistent_workshop)
    end
  end

  def end_start_valid_range!
    if end_date and start_date and (end_date < start_date)
      errors.add(:end_date, :date_range_invalid)
    end
  end
end
