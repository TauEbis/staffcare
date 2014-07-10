# Represents a projection of future volume at a particular location with 1-week granularity
#    VisitProjections are computed from these projections by applying them to a heat map.
class InputProjection < ActiveRecord::Base

  validates :volume_by_location, presence: true #TODO validate hash is greater than 0 and real locations
  # TODO: Appear to be several ways to validate a date string is good- want ISO (yyy-mm-dd) format
  validates :start_date, presence: true
  validates :end_date, presence: true

  scope :ordered, -> { order(start_date: :desc, id: :desc) }
  default_scope -> { order(start_date: :desc, id: :desc) }

end
