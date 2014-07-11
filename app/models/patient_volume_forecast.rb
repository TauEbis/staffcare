# Represents a projection of future volume at a particular location with 1-week granularity
#    VisitProjections are computed from these projections by applying them to a heat map.
class PatientVolumeForecast < ActiveRecord::Base

  validates :volume_by_location, presence: true #TODO validate hash is greater than 0 and real locations
  # TODO: Appear to be several ways to validate a date string is good- want ISO (yyy-mm-dd) format
  validates :start_date, presence: true
  validates :end_date, presence: true

  scope :ordered, -> { order(start_date: :desc, id: :desc) }
  default_scope -> { order(start_date: :desc, id: :desc) }

  def self.to_csv(options = {})
  	CSV.generate(options) do |csv|
  		locations = Location.ordered.all
  		attribute_columns = [ 'start_date', 'end_date' ]
  		location_columns = locations.map(&:name)
  		columns = ['id'] + attribute_columns + location_columns

  		csv << columns

  		ordered.all.each do |projection|
  			attribute_rows = projection.attributes.values_at(*attribute_columns)
  			location_rows = projection.volume_by_location.values_at(*locations.map(&:id).map(&:to_s))
				row = [projection.id] + attribute_rows + location_rows

				csv << row
			end

		end
  end

  def self.import(file)
  	locations = Location.ordered.all
  	CSV.foreach(file.path, headers:true) do |row|
			row = row.to_hash
			result = {}
			result["start_date"] = Date.parse(row["start_date"])
			result["end_date"] = Date.parse(row["end_date"])
			result["volume_by_location"] = {}
			locations.each do |location|
				result["volume_by_location"][location.id.to_s] = row[location.name]
			end
			projection = PatientVolumeForecast.find(row["id"]) || new

  		projection.update(result)
  		binding.pry unless projection.valid?
  		projection.save!
  	end
  end

end
