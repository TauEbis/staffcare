class Forecaster
#< ActiveRecord::Base
=begin

for migration:

location_id reference
ingest_id reference
start_date date
end_date date
visits json
degree integer
chunks integer
chunked_visits json
origins json
coeffs json

belongs_to :location
belongs_to :report_server_ingest
=end

# returns the forecast for a chunk of a date
def forecast(date, chunk)
	key = "#{date.day.short_name}_#{chunk}".to_sym

	x = (date-origins[key]).to_i
	coeffs[key].each_with_index.map { |c, i| c * x^i }.sum # polynomial
end

def self.build_from_ingest(ingest)
	chunks = 2 # hard coded to roughly am/pm (1/2 day)
	degree = 3 # hard coded to cubic
	start_date = ingest.start_date,
	end_date = ingest.end_date,
	locations = ingest.locations

	locations.each do |location|
		visits = ingest.get_visits(location)
		chunked_visits = self.build_chunks(visits, degree)

		attr = { location: location,
						 ingest: ingest,
						 start_date: start_date,
						 end_date: end_date,
						 visits: visits,
						 chunks: chunks,
						 degree: degree,
						 chunked_visits: chunked_visits, # {mon_0: {date: summed_visits} }
						 origins: self.build_origins(start_date, end_date, chunks), # {mon_1: date, mon_2: date}
						 coeffs: self.build_coeffs(chunked_visits) #(hash of arrays (14 * 4) )
						 }

		Forecaster.new(attr)
	end
end

def self.build_origins(start_date, end_date, chunks)
	origins = {}
	DAYS.EACH do |day|
		day_num = day.dow
		first_day = start_date.beginning_of_week + day_num.days
		last_day = end_date.beginning_of_week + day_num.days
		origin = (last_day + first_day)/2
		(o...chunks).each{ |x| origins["#{day}_#{x}".to_sym] = origin }
	end
end

def self.build_chunked_visits

end

# chunked_visits looks like {mon_0: [100, 200, 150, 125], mon_1: [100, 200, 150, 125], tues_0: [100, 200, 150, 125] ...}
def self.build_coeffs(chunked_visits, degree)
	coeffs={}
	chunked_visits.each do |key, chunk|
		coeffs[key] = (0..degree).map{ |d| oly_avg delta(chunk, d) }
	end
	coeffs
end

def self.oly_avg(arry)
	arry.map!(&:to_f) # do we want BigDecimals here?
	if arry.length > 2
		min = arry.min  # Do I want abs value for min and max?
		max = arry.max
		arry.delete_at(arry.index(min))
		arry.delete_at(arry.index(max))
	end
	arry.sum/(arry.length)
end

def self.delta(arry, degree)
	diff = arry[1..-1].zip(arry[0..-2]).map { |x, y| x - y } if degree != 0
	degree == 0 ? arry : self.delta(diff, degree-1)
end

end