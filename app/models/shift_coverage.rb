class ShiftCoverage

	SCORES 		= 					[0,0,0,0,0,0,0, 5, 10, 25, 30, 15, 20,  5,  10]
#					hours in day:	[0,1,2,3,4,5,6,  7,  8,  9, 10, 11, 12, 13, 14] scores for each shift length


  # TODO This needs some testing!
  def shifts_to_coverage(shifts)

    starts = shifts.map{|s| s.starts_hour}.sort.reverse
    ends   = shifts.map{|s| s.ends_hour}.sort.reverse

		a_shift = shifts.first
		opens_at = a_shift.grade.location_plan.open_times[a_shift.date.wday]
		closes_at = a_shift.grade.location_plan.close_times[a_shift.date.wday]

    cnt = 0
    coverage = []

    (opens_at...closes_at).step(0.5) do |hour|
      while starts[-1] == hour
        starts.pop
        cnt +=1
      end

      while ends[-1] == hour
        ends.pop
        cnt -=1
      end

      coverage << cnt
    end

    coverage
  end

  def coverage_to_shifts(coverage, location_plan, day)  # This method is only used for physician shifts currently
    @time = day.in_time_zone
		@opens_at = location_plan.open_times[day.wday]
		@closes_at = location_plan.close_times[day.wday]

		hours_open = @closes_at - @opens_at
		@min_shift = [(hours_open * 0.5).round, 6].max
		@midday = ( @opens_at + @closes_at )/2

  	shifts = pick_best(equiv_shifts_for(coverage))

    shifts.map do |starts_at, ends_at|
      Shift.new(starts_at: @time + starts_at.hours, ends_at: @time + ends_at.hours )
    end
  end

  def equiv_shifts_for(coverage)
  	opens, closes = coverage_opens_closes(coverage)
  	result = build_valid(opens, closes)
  	result
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

			if SCORES[(@closes_at - @opens_at)]
				best_score = score(pick)

				list.each do |set|
					if score(set) > best_score
						pick = set
						best_score = score(set)
					end
				end

			end

			pick
		end

		def score(set)
			set.map{ |shift| SCORES[ shift[1] - shift[0] ] }.sum / set.size.to_f
		end

		def coverage_opens_closes(coverage)
			@coverage = coverage
	    opens = shift_opens
	    closes = shift_closes

	    if ((diff = opens.size - closes.size) != 0)
	      opens, closes = normalize(opens, closes, diff)
	    end

	    return opens, closes
		end

	  def shift_opens
	    morning = @coverage[0..(@coverage.size/2)]

	    opens=Array.new(morning[0], @opens_at)

	    (1..(morning.size-1)).each do |index|
	      md_change = (morning[index] - morning[index-1])
	      md_change.times do |y|
	        hour = index/2 + @opens_at
	        opens << hour
	      end
	    end

	    opens
	  end

	  def shift_closes
	    evening = @coverage[(@coverage.size/2 -1)..-1]

	    closes = []

	    (1..(evening.size-1)).each do |index|
	      md_change = (evening[index-1] - evening[index])
	      md_change.times do |y|
	        hour =  @midday + (index-1)/2
	        closes << hour
	      end
	    end

	    evening[-1].times { |i| closes << @closes_at}

	    closes
	  end

	# TODO: determine if this case occurs and test it
	   def normalize(opens, closes, size_diff)

	    if size_diff < 0
	      size_diff.times { |i| opens << @midday }
	    elsif size_diff > 0
	      size_diff.times { |i| closes.unshift(@midday) }
	    end

	    return opens, closes

	  end

	  def build_valid(opens, closes)
			result = []
			opens.permutation.each do |o|
				result << o.zip(closes).sort
			end
			result=result.uniq

			result = result.reject do |set|
				reject = false
				set.each do |shift|
					reject = true if (shift[1]-shift[0] < @min_shift)
				end
				reject
			end

			found_splits = false
			result.each do |set|
				set.each do |shift|
					found_splits = true if shift[1]-shift[0] == 2 * @min_shift
				end
			end

			result = result + build_valid(opens+[@midday], closes+[@midday]) if found_splits
			result
		end

end
