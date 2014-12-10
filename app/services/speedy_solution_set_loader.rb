class SpeedySolutionSetLoader

  def load(grade, day)
    @_loaded_solution_sets ||= Hash.new

    key = grade.solution_set_options(day).to_s
    @_loaded_solution_sets[key] ||= grade.build_solution_set(day)
  end
end
