# Represents the speed at which a physician can see patients. Speeds are patients seen per hour.
# A normal speed and a max speed are given in patients seen per hour.
class Speed < ActiveRecord::Base

	belongs_to :location

  validates :location, presence: true
  validates :doctors, presence: true, numericality: { greater_than: 0, less_than: 100, only_integer: true },
  										uniqueness: { scope: :location, message: "must be unique per location" }#, unless "location_id.nil?"
  validates :normal, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :max, presence: true, numericality: { greater_than: :normal, less_than: 100 }, unless: "normal.nil?"

  scope :ordered, -> { order(doctors: :asc) }
  default_scope -> { order(doctors: :asc) }

end