# Represents a projection of future volume at a particular location with 1-week granularity
#    VisitProjections are computed from these projections by applying them to a heat map.
class PatientVolumeForecast < ActiveRecord::Base

  validates :volume_by_location, presence: true
  # TODO: Appear to be several ways to validate a date string is good- want ISO (yyy-mm-dd) format
  validates :start_date, presence: true, uniqueness: true
  validates :end_date, presence: true
  validate :legal_volume_by_location
  validate :valid_start_date, unless: "start_date.blank?"
  validate :valid_end_date, unless: "start_date.blank?"

  scope :ordered, -> { order(start_date: :asc, id: :desc) }
  default_scope -> { order(start_date: :asc, id: :desc) }


  # checks if the forecast includes data for the given date
  def contains_day?(date)
    if date >= self.start_date and date <= self.end_date
      return true
    else
      return false
    end
  end

  def contains_location?(loc)
    return self.volume_by_location.has_key?(loc.name)
  end

  #Returns the projected volume for the given location and day
  #NB: Right now returns the week volume for that day to match heatmaps
  def get_volume(location, day)
    return self.volume_by_location[location]
  end

  def valid_start_date
    unless start_date.is_a? Date
      errors.add(:start_date, "Please select a starting date.")
      return
    end

    unless start_date.friday?
      errors.add(:start_date, "Forecast week must start on a Friday.")
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
    volume_by_location.each do |site, volume|
         if volume.to_f < 0
              errors.add(:base, "#{site}: Value must be greater than zero")
         end
    end

=begin
    locations = Location.all
    location_names = locations.map(&:name)
    good_names = location_names & volume_by_location.keys
    if good_names.length < volume_by_location.keys.length
         errors.add(:volume_by_location, "invalid location name in volume data")
    end
=end
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
  			location_rows = projection.volume_by_location.values_at(*locations.map(&:name))
				row = [projection.id] + attribute_rows + location_rows

				csv << row
			end

		end
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      forecast = nil
      begin
        forecast = PatientVolumeForecast.find(row["id"])
      rescue ActiveRecord::RecordNotFound
        forecast = PatientVolumeForecast.new
      end

      result = {}
      result['volume_by_location'] = {}
      row.keys.each do |key|
        if key == 'start_date' or key == 'end_date' or key == 'id'
             result[key] = format_date(row[key])
        else
             result['volume_by_location'][key] = row[key].to_f
        end
      end

      forecast.update(result)
      forecast.save!
    end
  end

  def self.format_date(suspect)
     if suspect.include? '/'
       return Date.strptime(suspect, "%m/%d/%y").to_s
     else
       return suspect
     end
  end



  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Roo::CSV.new(file.path)
      when ".xls" then Roo::Excel.new(file.path)
      when ".xlsx" then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
