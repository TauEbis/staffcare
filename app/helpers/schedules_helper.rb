module SchedulesHelper
  def schedule_date_span(s)
    "#{l s.starts_on} - #{l s.ends_on}"
  end
end
