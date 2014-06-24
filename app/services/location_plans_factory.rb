class LocationPlansFactory

  def initialize(opts = {})
    @schedule      = opts[:schedule]
    @locations     = opts[:locations]
    @data_provider = opts[:data_provider]
  end

  def create(opts={})
    @visits_projections = VisitProjection.import!(@data_provider, @schedule, @locations)

    @schedule.location_plans.destroy_all

    @locations.each do |location|
      lp = LocationPlan.new(locations: location,
                            schedule: @schedule,
                            visit_projection: @visits_projection[location.report_server_id],
                            visits: @visits_projection[location.report_server_id].visits
                            )
      @schedule.location_plans << lp
      lp.save!
    end
  end

  #def update(opts={})
  #  @location_plans ||= Schedule.location_plans.all
  #
  #  @grader = CoverageGrader.new(grader_weights)
  #  reload_visits_projection if opts[:reload] # this will likely change to an ajax call
  #
  #  @location_plan.reoptimize(@grader, @visits_projection)
  #  @location_plan
  #end

  private
  #
  #def reoptimize(grader, visits_projection)
  #  @grader = grader
  #  @grader_weights = @grader.weights
  #  @visits_projection = visits_projection
  #
  #  @optimized_graded_coverage_plan = GradedResults.new(self)
  #  optimize
  #end
  #
  #def reload_visits_projection(opts={})
  #  @data_source = opts[:data_source] || get_data_source
  #  @data_provider = DataProvider.new(@data_source)
  #  @locations = opts[:locations] || dummy_locations
  #  @time_period = opts[:time_period] || dummy_time_period
  #  @visits_projection = opts[:visits_projection] || build_visits_projection
  #end


  # Eventually we may want to create a second coverage_options that is a (smaller) list of conceivable solutions not just all valid shifts
  def coverage_options(location, day)
    dow = Location::DAYS[day.wday]
    open = location.send("#{dow}_open".to_sym)
    close = location.send("#{dow}_close".to_sym)
    max_mds = location.max_mds
    CoverageOptions.new(open: open, close: close, max_mds: max_mds)
  end
end
