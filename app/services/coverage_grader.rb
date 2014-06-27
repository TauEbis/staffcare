class CoverageGrader

	def initialize(weights)

	  # Grader Function Coefficients

		@md_rate = weights[:md_rate].to_f # how many patients an MD sees an hour

		@penalty_slack = weights[:penalty_slack].to_f # penalty weight for doctor waiting with no patients to see

		@penalty_30min = weights[:penalty_30min].to_i # penalty weight for patient waiting 30 mins before seeing a doctor

		@penalty_60min = weights[:penalty_60min].to_i # penalty weight for patient waiting 60 mins before seeing a doctor

		@penalty_90min = weights[:penalty_90min].to_i # penalty weight for patient waiting 90 mins or more before seeing a doctor

		@penalty_eod_unseen = weights[:penalty_eod_unseen].to_i # penalty weight for patient not getting seen by end of day

		@round = weights[:round] || 2 # decimal places to calculate visits to

		# Derived Constants

		@md_half_hr_rate = @md_rate/2 # how many patients an MD sees in a half_hour

		@penalty_60min_to_90min = @penalty_90min - @penalty_60min

	end

	def penalty(coverage, day_visits)
		self.set_visits= day_visits
		penalty_with_set_visits(coverage)
  end

  def breakdown
    {
      queue: @queue,
      slack: @slack,
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

	def set_visits= (raw_visits)
		visits = raw_visits.map{ |visit| visit.round(@round) }
		@visits = visits
		@time_slots = @visits.size unless @visits.nil? # @time_slots is half hours slots in the work day
		@time_slots_range = (0...@time_slots)
		build_arrays
	end

	def penalty_with_set_visits(coverage)
		capacity = coverage.collect { |n| n * @md_half_hr_rate } # Physician capacity to see patients

		# Reset the initial conditions
		@queue[0], @thirty_min_wait[0], @greater_than_thirty_min_wait[0],
		@greater_than_sixty_min_wait[0], @greater_than_sixty_min_wait[1] = 0, 0, 0, 0, 0

		# Calculate slack and wait/queue arrays
		@time_slots_range.each do |x|
			@queue[x+1] = [ (@visits[x] + @queue[x] - capacity[x]), 0 ].max
			@slack[x] = [ capacity[x] - @visits[x] - @queue[x] , 0].max
			@greater_than_thirty_min_wait[x] = [ @queue[x] - @visits[x-1] , 0].max if x >= 1
			@thirty_min_wait[x] = @queue[x] - @greater_than_thirty_min_wait[x] if x >= 1
			@greater_than_sixty_min_wait[x] = [ @queue[x] - @visits[x-1] - @visits[x-2] , 0].max if x >= 2
		end

		# Calculate Penalty
		@time_slots_range.each do |x|
			@penalties[x] = @penalty_slack * @slack[x] +
											@penalty_30min * @thirty_min_wait[x] +
											@penalty_60min * @greater_than_thirty_min_wait[x] +
											@penalty_60min_to_90min * @greater_than_sixty_min_wait[x]
		end
		@penalties[@time_slots] = @penalty_eod_unseen * @queue[@time_slots]

    @hours_used = coverage.sum / 2

		@total_penalty = @penalties.inject(0) { | sum, x | sum + x }
	end

	private

		def build_arrays
			# Create arrays for penalty calc
			@slack = Array.new(@time_slots) # How should we type cast these? they are floats for now
			@greater_than_thirty_min_wait = Array.new(@time_slots) # greater than thirty min wait time per thirty min time slot
			@thirty_min_wait = Array.new(@time_slots) # wait time per thirty min time slot
			@greater_than_sixty_min_wait = Array.new(@time_slots) # wait time per thirty min time slot
			@queue = Array.new(@time_slots+1) # total queue length, 29th spot is unseen patients at end of day
			@penalties=Array.new(@time_slots+1) # penalty per thirty min time slot
		end

		def total_score
			@total_penalty.round(@round)
		end

		def md_sat_score
			score = @penalty_eod_unseen * @queue[@time_slots]
			score.round(@round)
		end

		def patient_sat_score
			@patient_sat = []
			@time_slots_range.each do |x|
				@patient_sat[x] =	@penalty_30min * @thirty_min_wait[x] +
													@penalty_60min * @greater_than_thirty_min_wait[x] +
													@penalty_60min_to_90min * @greater_than_sixty_min_wait[x]
			end
			score = @patient_sat.inject(0) { | sum, x | sum + x }
			score.round(@round)
		end

		def cost_score
			score = @slack.inject(0) { | sum, x | sum + @penalty_slack * x }
			score.round(@round)
		end

end
