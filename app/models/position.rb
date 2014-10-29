# A location record in the database- see LocationPlan for a record of how
# a location was configured when a schedule was generated.
class Position < ActiveRecord::Base

  has_many :shifts

  validates :name, uniqueness: true, presence: true
  validates :wiw_id, uniqueness: true, numericality: true, allow_nil: true
  validates :hourly_rate, numericality: true, presence: true

  scope :ordered, -> { order(name: :asc) }
  default_scope -> { order(name: :asc) }

end
