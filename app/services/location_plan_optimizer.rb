class LocationPlanOptimizer
  def initialize(location_plan)
    @location_plan = location_plan

    # These were originally items cached for ALL location_plans being optimized
    # But in order to run all location plan optimizations in separate processes, these
    # are now just variables here
    # If we were in a side-effect free functional language, these "coulda been constants"

    @schedule = @location_plan.schedule
    @grader = CoverageGrader.new(@schedule.grader_weights)
    @picker = CoveragePicker.new(@grader)
    @loader = SpeedySolutionSetLoader.new
  end

  def days
    @schedule.days
  end

  def optimize!
    coverages = {}
    breakdowns = {}
    points = {}
    shifts = []

    @grader.set_speeds @location_plan.normal, @location_plan.max

    @schedule.days.each do |day|
      day_visits = @location_plan.visits[day.to_s]
      # Load the valid shift start/stop times for that site and day
      solution_set = @loader.load(@location_plan, day)

      best_coverage, best_breakdown, best_points = @picker.pick_best(solution_set, day_visits)
      coverages[day.to_s] = best_coverage
      breakdowns[day.to_s] = best_breakdown
      points[day.to_s] = best_points
      shifts += ShiftCoverage.new(@location_plan, day).coverage_to_shifts(best_coverage)

      yield if block_given?
    end

    grade = @location_plan.grades.new(source: 'optimizer', coverages: coverages, breakdowns: breakdowns,
                                      points: points, shifts: shifts)

    grade.save!
    @location_plan.update_attribute(:chosen_grade_id, grade.id)
  end
end
