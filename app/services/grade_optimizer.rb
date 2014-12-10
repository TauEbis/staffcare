class GradeOptimizer

  # Using attr_accessor instead of doing a dependency injection
  attr_accessor :picker, :loader, :sc, :gen

  def initialize(grade)
    @grade = grade
    @schedule = @grade.schedule

    # These were originally items cached for ALL grades being optimized
    # But in order to run all grade optimizations in separate processes, these
    # are now just variables here
    # If we were in a side-effect free functional language, these "coulda been constants"

    grader = CoverageGrader.new(@grade.grader_opts) # Might be better as a dependency injection / instance variable
    @picker = CoveragePicker.new(grader)
    @loader = SpeedySolutionSetLoader.new
    @sc = ShiftCoverage.new
  end

  def optimize!
    coverages = {}
    breakdowns = {}
    points = {}
    shifts = []

    @grade.days.each do |day|
      # Load the valid shift start/stop times for that site and day
      solution_set = @loader.load(@grade, day)
      day_visits = @grade.visits[day.to_s]
      coverages[day.to_s], breakdowns[day.to_s], points[day.to_s] = @picker.pick_best(solution_set, day_visits)
      shifts += @sc.coverage_to_shifts(coverages[day.to_s], @grade, day)

      yield if block_given?
    end

    p = Position.find_by(key: :md)
    shifts.each{ |s| s.position = p}

    @grade.coverages = coverages
    @grade.breakdowns = breakdowns
    @grade.points = points
    @grade.shifts = shifts
    @grade.save!

    # FOOBAR
    # @location_plan.update_attribute(:chosen_grade_id, grade.id)

    create_non_md_shifts!(@grade)
  end

  #Non-Physician Shifts
  def create_non_md_shifts!(grade)
    Rule.copy_template_to_grade(grade)
    @gen = LineWorkerShiftGenerator.new(grade)
    @gen.create!
  end
end
