# A location record in the database- see LocationPlan for a record of how
# a location was configured when a schedule was generated.
class Position < ActiveRecord::Base

  has_many :shifts

  validates :name, uniqueness: true, presence: true
  validates :wiw_id, uniqueness: true, numericality: true, allow_nil: true
  validates :hourly_rate, numericality: true, presence: true
  validates :key, uniqueness: true, allow_nil: true

  scope :ordered, -> { order(name: :asc) }
  default_scope -> { order(name: :asc) }

  Key_Positions = {
    am: 				{ name: 'Assistant Manager', 							hourly_rate: 15 },
    ma: 				{ name: 'Medical Assistant', 							hourly_rate: 15 },
    manager: 		{ name: 'Manager', 												hourly_rate: 15 },
    md: 				{ name: 'Physician', 											hourly_rate: 180 },
    pcr: 				{ name: "Patient Care Representative", 		hourly_rate: 15 },
  	scribe: 		{ name: 'Scribe', 												hourly_rate: 15 },
    xray: 			{ name: "X-Ray Technician", 							hourly_rate: 15 }
  }.freeze


 	def self.create_key_positions
 		Key_Positions.each do |k, v|
 			Position.create(v.merge({key: k})) if Position.where(key: k).empty?
 		end
 	end

end
