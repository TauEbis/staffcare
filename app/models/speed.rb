# Represents the speed at which a physician can see patients. Speeds are patients seen per hour.
# A normal speed and a max speed are given in patients seen per hour.
class Speed < ActiveRecord::Base

	belongs_to :location

  validates :location, presence: true, on: :update #TODO can't do this on create since they both come from same form
  validates :doctors, presence: true, numericality: { greater_than: 0, less_than: 100, only_integer: true },
  										uniqueness: { scope: :location, message: "must be unique per location" }
  validates :normal, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :max, presence: true, numericality: { greater_than: :normal, less_than: 100 }, unless: "normal.nil?"
  #validates_associated :location #TODO this causes bugs in edge cases must be investigated

  scope :ordered, -> { order(doctors: :asc) }
  default_scope -> { order(doctors: :asc) }

end