class VolumeForecaster

	attr_reader :opts

	# Two class methods used for setting up forecasters

	# Finds locations with sufficient visit data for a forecast
	def self.locations_with_sufficient_data(date_range)
    Location.ordered.all.select do |location|
      location.visits.for_date_range(date_range.first, date_range.last).size == date_range.to_a.size
    end
  end

  # Finds the date range for a lookback window and a possible uppderbound
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

	def initialize(data_date_range, location, opts={})
		@opts = opts
		@opts[:chunks] ||= 2 	# Chunks: Volume chunks is 2 by default. Roughly am/pm (1/2 day)
		@opts[:degree] ||= 0 	# Polynomial degree is linear by default

		@data_start_date = data_date_range.first
		@data_end_date = data_date_range.last

		@visits = location.visits.for_date_range(@data_start_date, @data_end_date)
	  @coeffs = build_coeffs(@opts[:degree], @opts[:chunks]) 	# {sunday_0: [1,2,3,4], sunday_1: [1,2,3,4]}
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
		@coeffs[key].each_with_index.map { |c, i| c * x**i }.sum # return value of polynomial
	end

	# Dumps all visits data used by the forecaster
	def lookback_data
		lookback_data = {}
		@visits.each { |visit| lookback_data[visit.date] = visit.volumes }
		lookback_data
	end

	private

	#	Calculation starts here
		def dist_to_origin(date)
			dow = date.wday

			offset = (dow - @data_start_date.wday).modulo(7)
			first_dow = @data_start_date + offset.days

			offset = (@data_end_date.wday - dow).modulo(7)
			last_dow = @data_end_date - (offset).days

			origin = ((last_dow - first_dow).to_i/7) / (2.0)
			dist = (date-last_dow).to_i/7 + origin
			dist
		end

		# chunked_visits has form {monday_0: [100, 200, 150, 125], monday_1: [100, 200, 150, 125], tuesday_0: [100, 200, 150, 125] ...}
		def build_coeffs(degree, chunks)
			coeffs={}

			chunked_visits = build_chunked_visits(chunks) # {mon_0: [summed_visits_for_chunk_day_1, summed_visits_for_chunk_day_2, ...], ... }
			chunked_visits.each do |key, chunk|
				coeffs[key] = (0..degree).map{ |d| (oly_avg delta(chunk, d)) / factorial(d) }
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

		def factorial(x)
			(1..x).inject(:*) || 1
		end

		def oly_avg(arry)
			arry.map!(&:to_f) # do we want BigDecimals here?

			if arry.length > 2
				min = arry.min  # Do I want abs value for min and max?
				max = arry.max
				arry.delete_at(arry.index(min))
				arry.delete_at(arry.index(max))
			end

			arry.sum/(arry.length)
		end

		def delta(arry, degree)
			diff = arry[1..-1].zip(arry[0..-2]).map { |x, y| x - y } if degree != 0
			degree == 0 ? arry : delta(diff, degree-1)
		end

end