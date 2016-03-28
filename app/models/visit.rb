class Visit < ActiveRecord::Base
  belongs_to :order
  belongs_to :workshop

  validates :date, presence: true

  # Select all events occurring in a range
  #
  # +workshop+:: Workshop of interest
  # +from+:: Beginning of the selection
  # +end+:: End of the selection
  #
  # Both ends are excluded from the range
  def self.range(workshop, from, to)
    visits = Visit.
        where('date > :lo and date < :up',
          lo: from.to_formatted_s(:db),
          up: to.to_formatted_s(:db))
    visits = visits.where('order.workshop_id = :id', id: workshop.id) unless workshop.nil?
    visits
  end
end
