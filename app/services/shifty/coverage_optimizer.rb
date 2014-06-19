class CoverageOptimizer

	def optimize(locations, time_period, visits, grader_weights, results)

		grader = Grader.new(grader_weights) #add coverage grader
		loader = CoverageShiftSetListLoader.new

		locations.each do |location|
			time_period.days.each do |day|

				day_visits = visits.half_hr_visits[location.to_sym][day.to_s]
				daily_shift_set_list = loader.load(location, day)

				best_shift = grader.find_best(daily_shift_set_list, day_visits)
				results.shift_sets[location.to_sym][day.to_s] = best_shift
				results.penalties[location.to_sym][day.to_s] = grader.penalty(best_shift, day_visits)

			end
		end

	end
end