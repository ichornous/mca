class EventService < ActiveRecord::Base
  belongs_to :event
  belongs_to :service
end
