# Creates a LocationPlan using the provided options and data source
class LocationPlansFactory

  def initialize(opts = {})
    @schedule      = opts[:schedule]
    @locations     = opts[:locations]
    @data_provider = opts[:data_provider]
  end

  def create(opts={})
    @visit_projections = VisitProjection.import!(@data_provider, @schedule, @locations)

    @schedule.location_plans.destroy_all

    @locations.each do |location|
      attr = location.attributes.clone.slice(*LocationPlan::OPTIMIZER_FIELDS.map(&:to_s))
      attr.merge!({location: location,
                   visit_projection: @visit_projections[location.report_server_id],
                   visits: @visit_projections[location.report_server_id].visits,
                   open_times: location.open_times,
                   close_times: location.close_times
                 })

      lp = LocationPlan.new attr
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

end
