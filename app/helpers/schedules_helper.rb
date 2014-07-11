module SchedulesHelper
  def schedule_date_span(s)
    "#{l s.starts_on} - #{l s.ends_on}"
  end

  def schedule_daygrid(s)
    buf = []

    week = []
    # Insert the days of the month before the day of the week we start on
    s.starts_on.wday.times do
      week << nil
    end

    s.days.each do |day|
      if week.size == 7
        buf << week
        week = []
      end

      week << day
    end

    buf << week unless week.empty?

    buf
  end
end
