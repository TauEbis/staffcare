class Forecaster
#< ActiveRecord::Base
=begin
forecaster
location_id
ingest_id
start date
end date
chunks = 2 (1/2 day)
visits = array
coeff = (hash of arrays (14 * 3) )
origin = {mon_1: day}

def forecast(date, chunk)
	key= [#{date.day}_#{chunk}]
	coeff = coeff[key]
	origin = origin[key]
	x = date-origin

	coeff.each_with_index.map { |c, i| c * x^i }.sum
end

def self.build
	Forecaster.new(location, ingest)

	set_origins(start_date, end_date)

	visits = ingest.
	chunked_visits = self.chunk(visits)

	chunked_visits.each do |chunk|
		coeff[:mon_0][0] = oly_avg(chunk)
		coeff[:mon_0][1] = oly_avg(delta(chunk, 1))
		coeef[:mon_0][2] = oly_avg(delta(chunk, 2))
		coeef[:mon_0][3] = oly_avg(delta(chunk, 3))
	end
end
=end

def self.ol_avg(arry)
	arry.map!(&:to_f) # do we want BigDecimals here?
	min = arry.min
	max = arry.max
	arry.delete_at(arry.index(min))
	arry.delete_at(arry.index(max))

	arry.sum/(arry.length)
end

end
