class ShiftCoverage

				 	 	 #[0,1,2,3,4,5,6,  7,  8,  9, 10, 11, 12, 13, 14] scores for each shift length in hours
	SCORES 		= [0,0,0,0,0,0,0, 5, 10, 25, 30, 15, 20,  5,  10]
	MIN_SHIFT = 6

# This method is called by the grade to recalculate coverage after manual shift changes
  def shifts_to_coverage(shifts)

		a_shift = shifts.first
		opens_at = a_shift.grade.open_times[a_shift.date.wday]
		closes_at = a_shift.grade.close_times[a_shift.date.wday]

		coverage = Array.new((closes_at-opens_at) * 2, 0)
		shifts.each do |s|
			arrive = ( s.starts_hour - opens_at ) * 2
			leave =  ( s.ends_hour - opens_at ) * 2
			coverage[arrive...leave] = coverage[arrive...leave].map{ |x| x + 1 }
		end

		coverage
  end

# This method is only used for physician shifts currently -- All the methods beneath this are in the call chain of this method
  def coverage_to_shifts(coverage, grade, day)
    time = day.in_time_zone
		@opens_at = grade.open_times[day.wday]

		hours_open = grade.close_times[day.wday] - @opens_at
		@min_shift = [(hours_open * 0.5).round, MIN_SHIFT].max

  	shifts = pick_best(equiv_shifts_for(coverage))

    shifts.map do |starts_at, ends_at|
      Shift.new(starts_at: time + starts_at.hours, ends_at: time + ends_at.hours )
    end
  end

  def equiv_shifts_for(coverage)
  	opens, closes = opens_closes(coverage)
		build_valid(opens, closes)
  end

  def show_me(coverage)  # helper method for testing
		list = equiv_shifts_for(coverage)
		list.each do |set|
			puts "#{set.inspect} -- #{score(set)}"
		end
		puts "#{pick_best(list).inspect}"
	end

	private

		def pick_best(list)
			pick = list.first
			best_score = score(pick)

			list.each do |set|
				if score(set) > best_score
					pick, best_score = set, score(set)
				end
			end

			pick
		end

		def score(set)
			set.map{ |shift| SCORES[ shift[1] - shift[0] ] }.sum / set.size.to_f
		end

		def opens_closes(coverage)
	    opens=[]
	    closes=[]

			steps = (coverage+[0]).zip([0] + coverage).map{ |x,y| x-y }
			steps.each_with_index do |x, i|
				opens  += [i/2 + @opens_at]*x 		if x>0
				closes += [i/2 + @opens_at]*(-x)  if x<0
			end

	    return opens, closes
		end

	  def build_valid(opens, closes)
			result = []
			opens.permutation.each do |o|
				result << o.zip(closes).sort
			end
			result=result.uniq

			# 'set' is a set of shifts: eg. [[8,22], [13,22], [10,22]]
			result = result.reject do |set|
				reject = false
				set.each do |shift|
					reject = true if (shift[1]-shift[0] < @min_shift)
				end
				reject
			end

			# Splits can not happen when day is open for an odd number of hours or when the min_shift is not half the day length
			catch(:found_splits) do
				result.each do |set|
					set.each do |shift|
						if shift[1]-shift[0] == 2 * @min_shift
							midday = @opens_at + @min_shift
							result = result + build_valid(opens+[midday], closes+[midday])
							throw :found_splits
						end
					end
				end
			end

			result
		end

end
