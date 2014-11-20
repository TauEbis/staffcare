class SpeedySolutionSetLoader

  def load(location_plan, day)
    @_loaded_solution_sets ||= Hash.new

    key = location_plan.solution_set_options(day).to_s
    @_loaded_solution_sets[key] ||= location_plan.build_solution_set(day)
  end
end
