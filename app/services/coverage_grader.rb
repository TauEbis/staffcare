class CoverageGrader

	def initialize(weights)

	  # Grader Function Coefficients

		@penalty_slack = weights[:penalty_slack].to_f # penalty weight for doctor waiting with no patients to see

		@penalty_turbo = weights[:penalty_turbo].to_f # penalty weight for doctor working above normal speed

		@penalty_30min = weights[:penalty_30min].to_i # penalty weight for patient waiting 30 mins before seeing a doctor

		@penalty_60min = weights[:penalty_60min].to_i # penalty weight for patient waiting 60 mins before seeing a doctor

		@penalty_90min = weights[:penalty_90min].to_i # penalty weight for patient waiting 90 mins or more before seeing a doctor

		@penalty_eod_unseen = weights[:penalty_eod_unseen].to_i # penalty weight for patient not getting seen by end of day

		@normal_speeds = weights[:normal].map(&:to_f) # Normal physician work rate for different team sizes

		@max_speeds = weights[:max].map(&:to_f) # Max physician worl rate for different team sizes

		# Derived Constants

		@penalty_60min_to_90min = @penalty_90min - @penalty_60min

	end

	def full_grade(coverage, visits=nil)
		penalty(coverage, visits)
		return breakdown, points
	end

	def penalty(coverage, visits=nil)

		# Set provider capacity to see patients
		limit = @normal_speeds.length - 1 # Subtract 1 since normal[1] is first speed
		sheared_coverage = coverage.map { |n| [n,limit].min } # Assumption is that above the limit adding mds does not increase capacity
		normal_capacity = sheared_coverage.map { |n| @normal_speeds[n]/2 }
		max_capacity = sheared_coverage.map { |n| @max_speeds[n]/2 }
		@penalty_slack_vector = sheared_coverage.map { |n| n * @penalty_slack / @normal_speeds[[n,1].max] } # Sheared since this is slack in the system not waste in system.
		above_limit = (sheared_coverage != coverage)

		# Set visits and build arrays that depend on visits size
		if visits
			@visits = visits
			@time_slots = @visits.try(:size) # @time_slots is the number of half hours slots in the work day
			raise ArgumentError, 'timeslots for visits and coverage must be equal' unless @time_slots == coverage.size
			@time_slots_range = (0...@time_slots)
			build_arrays
		end

		# Reset the initial conditions
		@queue[0], @thirty_min_wait[0], @greater_than_thirty_min_wait[0],
		@greater_than_sixty_min_wait[0], @greater_than_sixty_min_wait[1] = 0, 0, 0, 0, 0

		# Calculate slack and wait/queue arrays
		@time_slots_range.each do |x|
			@seen[x] = [ @visits[x] + @queue[x], max_capacity[x] ].min
			delta = normal_capacity[x] - @seen[x]
			@slack[x] = [ delta , 0 ].max
			@turbo[x] = [ delta * (-1) , 0 ].max

			@queue[x+1] = @visits[x] + @queue[x] - @seen[x]
			@greater_than_thirty_min_wait[x] = [ @queue[x] - @visits[x-1] , 0].max if x >= 1
			@thirty_min_wait[x] = @queue[x] - @greater_than_thirty_min_wait[x] if x >= 1
			@greater_than_sixty_min_wait[x] = [ @queue[x] - @visits[x-1] - @visits[x-2] , 0].max if x >= 2
		end

		# Calculate Penalty
		# Note: Penalties are additive.
		# A 90 minute penalty will first have been penalized at the 30 minute rate and then at the 60 minute rate
		@time_slots_range.each do |x|
			@penalties[x] = @penalty_slack_vector[x] * @slack[x] +
											@penalty_turbo * @turbo[x] +
											@penalty_30min * @thirty_min_wait[x] +
											@penalty_60min * @greater_than_thirty_min_wait[x] +
											@penalty_60min_to_90min * @greater_than_sixty_min_wait[x]
		end
		@penalties[@time_slots] = @penalty_eod_unseen * @queue[@time_slots]
		@total_overstaffed_penalty = above_limit ? calc_overstaffed(coverage, sheared_coverage) : 0 # Gotcha: Will also silently adjust @penalties appropriately

    @hours_used = coverage.sum / 2

		@total_penalty = @penalties.sum
	end

	private

		def build_arrays
			# Create arrays for penalty calc
			@seen = Array.new(@time_slots) # How should we type cast these? they are floats for now
			@slack = Array.new(@time_slots) # How should we type cast these? they are floats for now
			@turbo = Array.new(@time_slots) # How should we type cast these? they are floats for now
			@greater_than_thirty_min_wait = Array.new(@time_slots) # greater than thirty min wait time per thirty min time slot
			@thirty_min_wait = Array.new(@time_slots) # wait time per thirty min time slot
			@greater_than_sixty_min_wait = Array.new(@time_slots) # wait time per thirty min time slot
			@queue = Array.new(@time_slots+1) # total queue length, 29th spot is unseen patients at end of day
			@penalties=Array.new(@time_slots+1) # penalty per thirty min time slot
		end

		# Methods used by #full_grade
	  def breakdown
	    {
	      queue: @queue,
	      seen: @seen,
	      turbo: @turbo,
	      slack: @slack, # patients who could be seen (without turboing) but are not seeen because there are not enough visitors
	      penalties: @penalties,
	      penalty: @total_penalty
	    }
	  end

	  def points
			{
				total: total_score,
				md_sat: md_sat_score,
				patient_sat: patient_sat_score,
				cost: cost_score,
	      hours: @hours_used
			}
	  end

		# Methods used to generate points
		def total_score
			@total_penalty
		end

		def md_sat_score
			score = @turbo.inject(0) { | sum, x | sum + @penalty_turbo * x }
			score += @penalty_eod_unseen * @queue[@time_slots]
			score
		end

		def patient_sat_score
			@patient_sat = []
			@time_slots_range.each do |x|
				@patient_sat[x] =	@penalty_30min * @thirty_min_wait[x] +
													@penalty_60min * @greater_than_thirty_min_wait[x] +
													@penalty_60min_to_90min * @greater_than_sixty_min_wait[x]
			end
			@patient_sat.sum
		end

		def cost_score
			@slack.zip(@penalty_slack_vector).map { | x, y| x * y }.sum + @total_overstaffed_penalty
		end

		def calc_overstaffed(coverage, sheared_coverage)
			overstaffing = coverage.zip(sheared_coverage).map{ |x, y| x - y }
			overstaffed_penalties = overstaffing.map{ |x| x * @penalty_slack / 2 }
			@time_slots_range.each do |x|
				@penalties[x] += overstaffed_penalties[x]
			end
			overstaffed_penalties.sum
		end

end
