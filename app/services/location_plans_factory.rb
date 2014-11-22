# Creates a LocationPlan using the provided options and data source
class LocationPlansFactory

  def initialize(opts = {})
    @schedule      = opts[:schedule]
    @locations     = opts[:locations]
    @data_provider = opts[:data_provider]
  end

  def create
    @locations.each do |location|

      attr = loc_attr(location).merge!(visit_attr(location))
      lp = LocationPlan.new attr
      @schedule.location_plans << lp
      lp.save!
    end
  end

  def update(opts = {})
    @locations.each do |location|

      attr = {}
      attr.merge!(loc_attr(location)) unless opts[:skip_visits]
      attr.merge!(visit_attr(location)) unless opts[:skip_locations]
      lp = @schedule.location_plans.find_by(location_id: location.id)
      lp.update! attr
    end
  end

  def loc_attr(location)
    attr = location.attributes.clone.slice(*LocationPlan::OPTIMIZER_FIELDS.map(&:to_s))
    attr.merge!({location:    location,
                 open_times:  location.open_times,
                 close_times: location.close_times,
                 normal:      [0] + location.speeds.ordered.map(&:normal),
                 max:         [0] + location.speeds.ordered.map(&:max)
               })
    attr
  end

  def visit_attr(location)
    @visit_projections ||= VisitProjection.import!(@data_provider, @schedule, @locations)

    {visit_projection: @visit_projections[location.report_server_id],
    visits: @visit_projections[location.report_server_id].visits}
  end

end
