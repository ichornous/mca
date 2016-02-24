class Visit < ActiveRecord::Base
  belongs_to :order
  belongs_to :workshop

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_start_valid_range!
  accepts_nested_attributes_for :order

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
  def end_start_valid_range!
    if end_date and start_date and (end_date < start_date)
      errors.add(:end_date, 'is not valid')
    end
  end
end
