class Inquiry < ActiveRecord::Base
  belongs_to :client
  belongs_to :car
  belongs_to :workshop
  belongs_to :order

  #
  # Scopes
  #
  scope :in_range, -> (from, to) { where('(date <= :up) and (:lo <= date)',
                                         lo: from.beginning_of_day.to_formatted_s(:db),
                                         up: to.end_of_day.to_formatted_s(:db)) }
  scope :in_workshop, -> (ws) { where(workshop_id: ws.id) }
end
