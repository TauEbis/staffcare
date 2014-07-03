require 'date'

# Represents a projection of future volume at a particular location with 1-week granularity
#    VisitProjections are computed from these projections by applying them to a heat map.
class InputProjection < ActiveRecord::Base
  has_one :location

  validates :location, presence: true
  validates :volume, numericality: { greater_than: 0 }
  # TODO: Appear to be several ways to validate a date string is good- want ISO (yyy-mm-dd) format
  validates :start_date, presense: true
  validates :end_date, presence: true

  #scope :ordered, -> { order(name: :asc) }

  #default_scope -> { order(name: :asc) }

  def initialize(start_date, end_date, location, volume)
       @start_date = Date.parse(start_date)
       @end_date = Date.parse(end_date)
       @location = location
       @volume = volume
  end

  


end
