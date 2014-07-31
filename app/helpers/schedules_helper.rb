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

  def total_points(record, zone = nil)
    "$#{points(record, zone, 'total')}"
  end

  def md_sat_points(record, zone = nil)
    "$#{points(record, zone, 'md_sat')}"
  end

  def patient_sat_points(record, zone = nil)
    "$#{points(record, zone, 'patient_sat')}"
  end

  def cost_points(record, zone = nil)
    "$#{points(record, zone, 'cost')}"
  end

  def hour_points(record, zone = nil)
    points(record, zone, 'hours')
  end

  private

    def points(record, zone, category)
      if record.is_a?(Schedule)
        if current_user.single_manager?
          location_plan = record.location_plans.for_user(current_user).first
          location_plan.unoptimized_summed_points[category].try(:round)
        else
          record.unoptimized_summed_points(zone)[category].try(:round)
        end
      elsif record.is_a?(LocationPlan)
        record.unoptimized_summed_points[category].try(:round)
      end
    end
end
