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

  def total_points(schedule, zone = nil)
    points(schedule, zone, 'total')
  end

  def md_sat_points(schedule, zone = nil)
    points(schedule, zone, 'md_sat')
  end

  def patient_sat_points(schedule, zone = nil)
    points(schedule, zone, 'patient_sat')
  end

  def cost_points(schedule, zone = nil)
    points(schedule, zone, 'cost')
  end

  private

    def points(schedule, zone, category)
      if current_user.single_manager?
        location_plan = schedule.location_plans.for_user(current_user).first
        location_plan.unoptimized_summed_points[category].try(:round)
      else
        schedule.unoptimized_summed_points(zone)[category].try(:round)
      end
    end
end
