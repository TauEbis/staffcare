class SolutionSetBuilder

  def build(coverage_options)
    @coverage_options = coverage_options
    @open = @coverage_options.open
    @close = @coverage_options.close
    @max_mds = @coverage_options.max_mds
    @min_openers = @coverage_options.min_openers
    @min_closers = @coverage_options.min_closers

    @set = @coverage_options.get_solution_set_for_builder

    build_solution_set
    @coverage_options
  end

  private

  def build_solution_set

    combinations = (1..(@coverage_options.openings + @coverage_options.openers_to_assign - 1 )).to_a.combination(@coverage_options.openers_to_assign).to_a

    combinations.each do |am_combos|
      am_steps = am_combos.map.with_index { |el, index | el + @coverage_options.open - (index + 1) }

      combinations.each do |pm_combos|
        pm_steps = pm_combos.map.with_index { |el, index | el + @coverage_options.first_possible_close - (index + 1) }
        steps = am_steps + pm_steps

        shifts = @coverage_options.fixed_openers + steps + @coverage_options.fixed_closers # eg add [8] at begining and [22] at the end

        if valid?(shifts, @coverage_options.min_shift)
          @set<<shifts
        end

      end
    end
  end

  def valid?(shifts, min_shift) # checks to see if the open and close times in a shift are satisfiable given the @min_shift
    midday_pairs = midday_pairs(shifts)
    if (midday_pairs == set_size/2)
      return false
    else
      (0..(set_size/2 - midday_pairs -1)).each do |x|
        return false if (shifts[set_size/2 + midday_pairs + x] - shifts[x] < min_shift)
      end
    end
    return true
  end

  def midday_pairs(shifts) # this method returns how many pairs of redundant open close pairs exist at midday
    if shifts.index(@coverage_options.midday)
      midday_opens = [(set_size/2) - shifts.index(@coverage_options.midday), 0].max
      midday_closes = [shifts.rindex(@coverage_options.midday) - set_size/2 +1, 0].max
      midday_pairs = [midday_opens, midday_closes].min
    else
      0
    end
  end

  def set_size
    @coverage_options.set_size
  end
end
