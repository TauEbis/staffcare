# A zone is a collection of locations/sites
class Zone < ActiveRecord::Base
  has_many :locations

  scope :ordered, -> { order(name: :asc) }

  # Removed because it interferes with distinct
  #default_scope -> { order(name: :asc) }

  validates :name, presence: true

  def to_s
    name
  end
end
