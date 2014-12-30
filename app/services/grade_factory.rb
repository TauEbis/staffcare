# Creates a Grade using the provided options and data source
class GradeFactory

  attr_accessor :projector

  def initialize(opts = {})
    @schedule = opts[:schedule]
    @volume_source = opts[:volume_source]
    @projector = opts[:projector] || VisitProjector.new
  end

  def create
    @locations = Location.assigned # Exclude Locations in the 'Unassigned' zone
    @locations.each do |location|
      lp = @schedule.location_plans.create!(location: location)

      attr = loc_attr(location).merge!(visit_attr(location))
      attr[:source] = 'optimizer'

      grade = Grade.new attr
      grade.schedule = @schedule
      grade.location_plan = lp
      grade.save!
      lp.chosen_grade = grade
      lp.save!
    end
  end

  def update(opts = {})
    @locations = Location.for_schedule(@schedule)
    @locations.each do |location|
      attr = {}
      attr.merge!(loc_attr(location)) if opts['load_locations']
      attr.merge!(visit_attr(location)) if opts['load_visits']
      grade = @schedule.grades.find_by(location_id: location.id)
      grade.update! attr
    end
  end

  private

    def loc_attr(location)
      attr = location.attributes.clone.slice(*Grade::OPTIMIZER_FIELDS.map(&:to_s))
      attr.merge!({ location:    location,
                    open_times:  location.open_times,
                    close_times: location.close_times,
                    normal:      [0] + location.speeds.ordered.map(&:normal),
                    max:         [0] + location.speeds.ordered.map(&:max)
                 })
      attr
    end

    def visit_attr(location)
      @_visit_projection = @projector.project!(location, @schedule, @volume_source)
      { visit_projection: @_visit_projection, visits: @_visit_projection.visits }
    end

end
