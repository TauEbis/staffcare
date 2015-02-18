class VolumeForecaster

	attr_reader :opts

	def initialize(data_date_range, location, opts={})
		@opts = opts
		@opts[:chunks] ||= 2 	# Chunks: Volume chunks is 2 by default. Roughly am/pm (1/2 day)

		@data_start_date = data_date_range.first
		@data_end_date = data_date_range.last

		@visits = location.visits.for_date_range(data_date_range)
	  @coeffs = build_coeffs(@opts[:chunks]) 	# {sunday_0: [1,2,3,4], sunday_1: [1,2,3,4]}
	end

	# Returns a full location forecast as arrays of volumes indexed by chunk and hashed by date
	def full_forecast(start_date, end_date)
		full_forecast={}
		(start_date..end_date).each do |date|
			full_forecast[date] = []
			(0..opts[:chunks]-1).each do |chunk|
				full_forecast[date] << forecast(date, chunk)
			end
		end
		full_forecast
	end

	# Returns the location forecast for a chunk of a date
	def forecast(date, chunk)
		key = key(date, chunk)
		x = dist_to_origin(date)

		y = @coeffs[key][0] + @coeffs[key][1] * Math.log(x + @coeffs[key][2]) # return value of a + b * ln (x+c)
		return [y,0].max
	end

	# Dumps all visits data used by the forecaster
	def lookback_data
		lookback_data = {}
		@visits.each { |visit| lookback_data[visit.date] = visit.volumes }
		lookback_data
	end

	# Two class methods used for setting up forecasters

	# Finds locations with sufficient visit data for a forecast
	def self.locations_with_sufficient_data(date_range)
    Location.ordered.all.select do |location|
      location.visits.for_date_range(date_range).size == date_range.to_a.size
    end
  end

  # Finds the date range for a lookback window and a possible upperbound
	def self.calc_data_date_range(lookback_window = 10, upper_bound = nil) # upper_bound is < not <=
		if upper_bound
			last_visit_date = [upper_bound - 1.days, Visit.ordered.last.date].min
		else
			last_visit_date = Visit.ordered.last.date
		end
		data_end_date = last_visit_date.wday == 6 ? last_visit_date : last_visit_date - last_visit_date.wday - 1.days # A Saturday
		data_start_date = data_end_date - lookback_window.weeks + 1.days # A Sunday

		data_start_date..data_end_date
	end

	private

	#	Calculation starts here
		def dist_to_origin(date)
			dow = date.wday

			offset = (dow - @data_start_date.wday).modulo(7)
			first_dow = @data_start_date + offset.days

			dist = (date-first_dow).to_i/7 + 1
			dist
		end

		# chunked_visits has form {monday_0: [100, 200, 150, 125], monday_1: [100, 200, 150, 125], tuesday_0: [100, 200, 150, 125] ...}
		def build_coeffs(chunks)
			coeffs={}

			chunked_visits = build_chunked_visits(chunks) # {mon_0: [summed_visits_for_chunk_day_1, summed_visits_for_chunk_day_2, ...], ... }
			chunked_visits.each do |key, chunk|
				len = chunk.size

				x_data = (1..len).to_a
				log_x_data = x_data.map { |x| Math.log(x) }
				y_data = chunk

				x_vector = x_data.to_vector(:scale)
				x_log_vector = log_x_data.to_vector(:scale)
				y_vector = y_data.to_vector(:scale)

				ds = {'x'=>x_vector,'y'=>y_vector}.to_dataset
				log_ds = {'x'=>x_log_vector,'y'=>y_vector}.to_dataset

				mlr = Statsample::Regression::Simple.new_from_vectors(x_vector,y_vector)
				m = mlr.b

				log_mlr = Statsample::Regression::Simple.new_from_vectors(x_log_vector,y_vector)
				n = log_mlr.b
				n = n.abs * m/m.abs

				co_b = len**2 * m**2/n
				co_c = len**2 * (m/n) - len
				co_a = mlr.y(len) - co_b * Math.log(len+co_c)

				coeffs[key] = [ co_a, co_b, co_c ]
			end
			coeffs
		end

		def build_chunked_visits(chunks)
			chunked_visits = {}

			@visits.each do |visit|
				chunked_visit = visit.in_chunks(chunks)
				(0..(chunks-1)).each do |chunk|
	        key = key(visit.date, chunk)
					chunked_visits[key] ||= []
					chunked_visits[key] << chunked_visit[chunk]
				end
			end

			chunked_visits
		end

		def key(date, chunk)
			"#{Date::DAYNAMES[date.wday]}_#{chunk}".to_sym
		end

end