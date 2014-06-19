class Grader

	def initialize(weights)

	  # Grader Function Coefficients

		@md_rate = weights[:md_rate] # how many patients an MD sees an hour

		@penalty_slack = weights[:penalty_slack] # penalty weight for doctor waiting with no patients to see

		@penalty_30min = weights[:penalty_30min] # penalty weight for patient waiting 30 mins before seeing a doctor

		@penalty_60min = weights[:penalty_60min] # penalty weight for patient waiting 60 mins before seeing a doctor

		@penalty_90min = weights[:penalty_90min] # penalty weight for patient waiting 90 mins or more before seeing a doctor

		@penalty_eod_unseen = weights[:penalty_eod_unseen] # penalty weight for patient not getting seen by end of day

	end

	def find_best(shift_sets, daily_visits)
		@visits = daily_visits

		best_shift_set = shift_sets.first
		min_penalty = penalty_fixed_visits(best_shift_set)

		shift_sets.each do |shift_set|
			pen = penalty_fixed_visits(shift_set)
			if (pen < min_penalty)
				best_shift_set = shift_set
				min_penalty = pen
			end
		end

		best_shift_set
	end

	def penalty(shift_set, daily_visits)
		@visits = daily_visits

		# TODO: This will error out unless visits are set. But I don't want to check every time with an if loop. What to do..

			# FIXME: This is the staffing step function
		staffing_progression = (1..(shift_set.size/2)).to_a + (shift_set.size/2-1).downto(1).to_a

		md_nums = [] #Array.new(time_slots) # mds present per half-hour shift
		(1...shift_set.size).each do |y|
			( 2 * (shift_set[y] - shift_set[y-1]) ).times { md_nums << staffing_progression[y-1] }
		end

		# Create arrays for penalty calc
		slack = Array.new(time_slots, 0) # How should we type cast these? they are floats for now
		greater_than_thirty_min_wait = Array.new(time_slots, 0) # greater than thirty min wait time per thirty min time slot
		thirty_min_wait = Array.new(time_slots, 0) # wait time per thirty min time slot
		greater_than_sixty_min_wait = Array.new(time_slots, 0) # wait time per thirty min time slot
		queue = Array.new(time_slots+1, 0) # total queue length, 29th spot is unseen patients at end of day
		penalties=Array.new(time_slots+1, 0) # penalty per thirty min time slot

		# Calculate slack and wait/queue arrays
		(0...time_slots).each do |x|
			queue[x+1] = [ (@visits[x] + queue[x] - @md_rate/2 * md_nums[x]), 0 ].max
			slack[x] = [ @md_rate/2 * md_nums[x] - @visits[x] - queue[x] , 0].max
			greater_than_thirty_min_wait[x] = [ queue[x] - @visits[x-1] , 0].max if x >= 1
			thirty_min_wait[x] = queue[x] - greater_than_thirty_min_wait[x] if x >= 1
			greater_than_sixty_min_wait[x] = [ queue[x] - @visits[x-1] - @visits[x-2] , 0].max if x >= 2
		end

		# Calculate Penalty
		(0...time_slots).each do |x|
			penalties[x] = @penalty_slack * slack[x] + @penalty_30min * thirty_min_wait[x] +
			@penalty_60min * greater_than_thirty_min_wait[x] +
			(@penalty_90min - @penalty_60min) * greater_than_sixty_min_wait[x]
		end
		penalties[time_slots] = @penalty_eod_unseen * queue[time_slots]

		total_penalty = penalties.inject(0) { | sum, x | sum + x }

	end

	private

		def penalty_fixed_visits(shift_set)
			penalty(shift_set, @visits)
		end

		def time_slots # half hours in the day
			@visits.size
		end

		def check_visits_length_and_shift_set_span_agree # TODO
			# timeslots = 2* (shift_set[-1]-shift_set[0] )
		end

end