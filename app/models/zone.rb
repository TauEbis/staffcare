# A zone is a collection of locations/sites
# Schedulers are defined to have authority over a particular zone.
class Zone < ActiveRecord::Base
  has_many :locations
  has_many :memberships
  has_many :users, through: :memberships

  scope :ordered, -> { order(name: :asc) }

  default_scope -> { order(name: :asc) }

  validates :name, presence: true

  def to_s
    name
  end
end
