module SchedulesHelper
  def schedule_date_span(s)
    "#{(l s.starts_on).slice(0..-7)} - #{l s.ends_on}"
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
    number_to_currency points(record, zone, 'total'), precision: 0
  end

  def md_sat_points(record, zone = nil)
    number_to_currency points(record, zone, 'md_sat'), precision: 0
  end

  def patient_sat_points(record, zone = nil)
    number_to_currency points(record, zone, 'patient_sat'), precision: 0
  end

  def cost_points(record, zone = nil)
    number_to_currency points(record, zone, 'cost'), precision: 0
  end

  def hour_points(record, zone = nil)
    number_with_delimiter points(record, zone, 'hours')
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
