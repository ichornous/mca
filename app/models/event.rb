class Event < ActiveRecord::Base
  has_and_belongs_to_many :employees
  has_many :event_services
  has_many :services, :through => :event_services

  # Select all events occurring in a range
  #
  # +from+:: Beginning of the selection
  # +end+:: End of the selection
  #
  # Both ends are excluded from the range
  def self.between(from, to)
    where('start > :lo and start < :up',
          lo: from.to_formatted_s(:db),
          up: to.to_formatted_s(:db)
    )
  end
end
