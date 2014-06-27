module LocationsHelper
  def hours_options
    @_hours_options ||= begin
      (6..24).map do |h|
        [time_of_day(h), h*60]
      end
    end
  end
end
