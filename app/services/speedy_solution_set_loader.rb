class SpeedySolutionSetLoader

  def initialize
    @loaded_solution_sets = Hash.new
  end

  def load(location_plan, day)
    coverage_options = location_plan.coverage_options(day)
    key = coverage_options.opts_key

    if !@loaded_solution_sets.has_key?(key)
      @loaded_solution_sets[:key] = coverage_options.solution_set
    end

    @loaded_solution_sets[:key]
  end
end
