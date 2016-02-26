class Event < ActiveRecord::Base
  has_and_belongs_to_many :employees
  has_many :event_services
  has_many :services, :through => :event_services
  belongs_to :workshop

  validates :start, presence: true
  validates :end, presence: true

  # Select all events occurring in a range
  #
  # +workshop+:: Workshop of interest
  # +from+:: Beginning of the selection
  # +end+:: End of the selection
  #
  # Both ends are excluded from the range
  def self.range(workshop, from, to)
    workshop.events.
        where('start > :lo and start < :up',
          lo: from.to_formatted_s(:db),
          up: to.to_formatted_s(:db))
  end
end
