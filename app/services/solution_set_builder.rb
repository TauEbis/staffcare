# Loads the possible combinatoric set of valid shifts for a given day
# given the constraints stored as a location_plan
class SolutionSetBuilder

  def initialize(location_plan, day)
    @location_plan = location_plan
    @open = @location_plan.open_times[day.wday]
    @close = @location_plan.close_times[day.wday]
    @max_mds = @location_plan.max_mds
    @min_openers = @location_plan.min_openers
    @min_closers = @location_plan.min_closers

    @hours_open = @close - @open # half hours in the day

    @min_shift = @hours_open / 2 # shortest allowable shift
    @fixed_openers = Array.new(@min_openers, @open) # Fixed openers
    @fixed_closers = Array.new(@min_closers, @close) # Fixed closers
    @first_possible_close = @open + @min_shift # first time to end a shift
    @last_possible_open = @close - @min_shift # last time to start a shift
    @openings = @last_possible_open - @open + 1 # number of possible shift opens -- equal to @closings
    @closings = @close - @first_possible_close + 1 # number of possible shift closes -- equal to @openings
    @midday = @open + @hours_open / 2 # midday shift which happens to also be the only time shifts can both start and stop
    @openers_to_assign = @max_mds - @min_openers
    @closers_to_assign = @max_mds - @min_closers
    # TODO: set_size is the number of elements in a shift set.
    # It is twice max_mds, because minshift is half the working day.
    # Further explanation given on readme.
    @set_size = @max_mds * 2
    @half_set_size = @max_mds
    @full_coverage = Array.new(@half_set_size, @open) + Array.new(@half_set_size, @close)
    @time_slots = @hours_open * 2 # half hour time slots in the day
    @staffing_progression = (1..(@half_set_size)).to_a + (@half_set_size-1).downto(1).to_a
    @difference_range = 0...(@set_size-1)
  end

  def build
    @set = Array.new

    am_combinations = (1..(@openings + @openers_to_assign - 1 )).to_a.combination(@openers_to_assign).to_a
    if @min_openers == @min_closers
      pm_combinations = am_combinations
    else
      pm_combinations = (1..(@closings + @closers_to_assign - 1 )).to_a.combination(@closers_to_assign).to_a
    end

    am_combinations.each do |am_combos|
      am_steps = am_combos.map.with_index { |el, index | el + @open - (index + 1) }

      pm_combinations.each do |pm_combos|
        pm_steps = pm_combos.map.with_index { |el, index | el + @first_possible_close - (index + 1) }
        steps = am_steps + pm_steps

        shifts = @fixed_openers + steps + @fixed_closers # eg add [8] at begining and [22] at the end

        if valid?(shifts, @min_shift)
          @set << expand_coverage(shifts)
        end

      end
    end

    @set
  end


  private

    def expand_coverage(shifts)
      coverage = Array.new

      for i in @difference_range
        length = 2 * (shifts[i+1] - shifts[i])
        coverage += Array.new(length, @staffing_progression[i])
      end

      coverage
    end

# Would this be faster?
#      (1...@set_size).each do |y|
#        ( 2 * (shifts[y] - shifts[y-1]) ).times { coverage << @staffing_progression[y-1] }
#      end

    def valid?(shifts, min_shift) # checks to see if the open and close times in a shift are satisfiable given the @min_shift
      midday_pairs_result = midday_pairs(shifts)
      if (midday_pairs_result == @half_set_size)
        return false
      else
        (0..(@half_set_size - midday_pairs_result - 1)).each do |x|
          return false if (shifts[@half_set_size + midday_pairs_result + x] - shifts[x] < min_shift)
        end
      end
      return true
    end

    def midday_pairs(shifts) # this method returns how many pairs of redundant open close pairs exist at midday
      if shifts.index(@midday)
        midday_opens = [@half_set_size - shifts.index(@midday), 0].max
        midday_closes = [shifts.rindex(@midday) - @half_set_size + 1, 0].max
        midday_pairs = [midday_opens, midday_closes].min
      else
        0
      end
    end
end
