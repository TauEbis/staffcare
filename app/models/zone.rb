# A zone is a collection of locations/sites
class Zone < ActiveRecord::Base
  has_many :locations

  scope :ordered, -> { order(name: :asc) }
  scope :not_empty, -> { where(id: Location.ordered.pluck(:zone_id).uniq) }
  scope :assigned, -> { not_empty.where.not(name: "Unassigned") }
  scope :for_schedule, -> (schedule) { where(id: schedule.zones) }

  # Removed because it interferes with distinct
  #default_scope -> { order(name: :asc) }

  validates :name, presence: true

  def to_s
    name
  end
end
