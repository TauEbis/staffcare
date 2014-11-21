# Loads the possible combinatoric set of valid shifts for a given day
# given the constraints stored in a location_plan
class SolutionSetBuilder

  def setup(options)
    @open        = options[:open]
    @close       = options[:close]
    @max_mds     = options[:max_mds]
    @min_openers = options[:min_openers]
    @min_closers = options[:min_closers]

# Derived instance variables
    @hours_open = @close - @open # hours in the day
    @min_shift = (@hours_open * 0.5).round # shortest allowable shift

    @first_possible_close = @open + @min_shift # first time to end a shift
    @last_possible_open = @close - @min_shift # last time to start a shift

    @openings = @last_possible_open - @open + 1 # number of possible shift opens -- equal to @closings
    @openers_to_assign = @max_mds - @min_openers
    @closings = @close - @first_possible_close + 1 # number of possible shift closes -- equal to @openings
    @closers_to_assign = @max_mds - @min_closers

    @fixed_openers = Array.new(@min_openers, @open) # Fixed openers
    @fixed_closers = Array.new(@min_closers, @close) # Fixed closers

    @midday = @open + @hours_open / 2 # midday shift which happens to also be the only time shifts can both start and stop

    @set_size = @max_mds * 2 # set_size is the number of elements in a shift set. It is twice max_mds, because minshift is half the working day. Further explanation given on the shifty readme.
    @half_set_size = @max_mds # half @set_size
    @staffing_progression = (1..(@half_set_size)).to_a + (@half_set_size-1).downto(1).to_a
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

        if valid?(shifts)
          @set << expand_coverage(shifts)
        end

      end
    end

    @set
  end

  private

# Expands terse reprentation to covearge representation
    def expand_coverage(shifts)
      @staffing_progression.flat_map.with_index{ |x, i| Array.new(2*(shifts[i+1] - shifts[i]), x) }
    end

# Checks to see if the open and close times in a shift are satisfiable given the @min_shift
    def valid?(shifts)
      real_shifts = @half_set_size - midday_pairs(shifts)
      return false if real_shifts == 0
      shifts[-real_shifts..-1].zip(shifts[0...real_shifts]).each { |x,y| return false if x-y < @min_shift }
      return true
    end

 # Returns how many pairs of redundant open close pairs exist at midday
    def midday_pairs(shifts)
      if shifts.include?(@midday)
        @half_set_size - [shifts.index(@midday), shifts.reverse.index(@midday)].max
      else
        0
      end
    end
end
