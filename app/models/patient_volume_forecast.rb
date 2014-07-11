# Represents a projection of future volume at a particular location with 1-week granularity
#    VisitProjections are computed from these projections by applying them to a heat map.
class PatientVolumeForecast < ActiveRecord::Base

  validates :volume_by_location, presence: true 
  # TODO: Appear to be several ways to validate a date string is good- want ISO (yyy-mm-dd) format
  validates :start_date, presence: true, uniqueness: true
  validates :end_date, presence: true
  #validate :legal_volume_by_location
  validate :valid_start_date, unless: "start_date.blank?"
  validate :valid_end_date, unless: "start_date.blank?"

  scope :ordered, -> { order(start_date: :asc, id: :desc) }
  default_scope -> { order(start_date: :asc, id: :desc) }


  def valid_start_date
    unless start_date.is_a? Date
      errors.add(:start_date, "Please select a starting date.")
      return
    end

    unless start_date.sunday?
      errors.add(:start_date, "Forecast week must start on a Sunday.")
    end
  end

  def valid_end_date
    unless end_date.is_a? Date
      errors.add(:end_date, "Please select an end date")
      return
    end

    unless end_date == start_date + 6
      errors.add(:end_date, "End data and start date must be one week apart")
    end
  end

  #TODO validate hash is greater than 0 and real locations
  def legal_volume_by_location
    if volume_by_location.keys.length <= 0
         errors.add(:volume_by_location, "must include at least one location")
    end
    volumes = volume_by_location.values
    volumes.each do |volume|
         if volume < 0
              errors.add(:volume_by_location, "volumes must be greater than zero")
         end
    end

    locations = Location.all
    location_names = locations.map(&:name)
    good_names = location_names & volume_by_location.keys
    if good_names.length < volume_by_location.keys.length
         errors.add(:volume_by_location, "invalid location name in volume data")
    end
  end

  # Exports only forecasts that start on a date after today
  def self.to_csv(options = {})
  	CSV.generate(options) do |csv|
  		locations = Location.ordered.all
  		attribute_columns = [ 'start_date', 'end_date' ]
  		location_columns = locations.map(&:name)
  		columns = ['id'] + attribute_columns + location_columns

  		csv << columns

  		ordered.all.each do |projection|
        unless projection.start_date > Date.today
          next
        end
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
      # result["start_date"] = row['start_date'].include?('/') ? Date.strptime(row['start_date'], '%m/%d/%y') : result["start_date"]
      # something like this ....
			result["volume_by_location"] = {}
			locations.each do |location|
				result["volume_by_location"][location.id.to_s] = row[location.name]
		  end
      projection = nil
      begin
		    projection = PatientVolumeForecast.find(row["id"]) 
      rescue ActiveRecord::RecordNotFound
        projection = PatientVolumeForecast.new
      end

  		projection.update(result)
  		projection.save!
  	end
  end

end
