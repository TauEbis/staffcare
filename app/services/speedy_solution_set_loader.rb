class SpeedySolutionSetLoader

  def initialize
    @loaded_solution_sets = Hash.new
  end

  def load(location_plan, day)
    solution_set_options = location_plan.solution_set_options(day)
    key = solution_set_options.to_s

    if !@loaded_solution_sets.has_key?(key)
      @loaded_solution_sets[key] = location_plan.build_solution_set(day)
    end

    @loaded_solution_sets[key]
  end
end
