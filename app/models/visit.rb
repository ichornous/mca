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
        where('start_date > :lo and end_date < :up',
              lo: from.to_formatted_s(:db),
              up: to.to_formatted_s(:db))
  end

  private
  def init!
    self.color ||= Visit.event_colors[0]
  end

  def workshop_consistent!
    return if order.nil?
    if order.workshop != workshop
      errors.add(:workshop, 'inconsistent with the order')
    end
  end

  def end_start_valid_range!
    if end_date and start_date and (end_date < start_date)
      errors.add(:end_date, 'is not valid')
    end
  end
end
