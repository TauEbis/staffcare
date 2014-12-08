class Analysis

  LETTERS  = {  "F"  => 5.00,
                "D-" => 4.33, # no F+ so bigger step here
                "D"  => 4.00,
                "D+" => 3.67,
                "C-" => 3.33,
                "C"  => 3.00,
                "C+" => 2.67,
                "B-" => 2.33,
                "B"  => 2.00,
                "B+" => 1.67,
                "A-" => 1.33,
                "A"  => 0.75,
                "A+" => 0.0
              }

  def initialize(grades, date = nil)
    @grades = Array(grades)

    if date && @grades.length > 1
      raise ArgumentError, "You can only specify a date on a single grade"
    end

    # The assumption here is all grades are part of the same schedule
    # We dont' check for it because it's expensive
    @schedule = @grades.first.location_plan.schedule

    @days = date ? Array(date) : @schedule.days
  end

  def to_knockout
    {
      points: points,
      letters: letters,
      stats: stats
    }
  end

  def points
    @_points ||= begin
      points = Hash.new(0)

      @grades.each do |g|
        @days.each do |day|
          p = g.points[day.to_s]
          ['total', 'md_sat', 'patient_sat', 'cost', 'hours'].each do |field|
            points[field] += p[field]
          end
        end
      end

      points
    end
  end

  def letters
    @_letters ||= begin

      letters = {}

      my_sums = points.except("hours")
      opt_sums = Analysis.new(@grades.map(&:plans_optimized_grade)).points.except("hours")

      my_sums.each do |k1, v1|
        if k1 == "total"
          letters[k1] = self.class.assign_letter ( my_sums[k1] / opt_sums[k1])
        else
          letters[k1] = self.class.assign_letter ( my_sums[k1] /( ( opt_sums["total"] / 3 + opt_sums[k1]) /2 ) )
        end
      end

      letters
    end
  end

  def stats
    @_stats ||= begin
      ppp = totals[:penalty] / totals[:visits] rescue 0
      wr  = totals[:visits] / totals[:coverage] rescue 0  # patients per hour

      {
        wages: (totals[:coverage] * @schedule.penalty_slack).to_f,
        wait_time: totals[:queue] * 30,  # in minutes
        work_rate: wr,
        pen_per_pat: ppp,
        wasted_time: totals[:wasted_time]
      }
    end
  end

  def totals
    @_totals ||= begin

      @_totals = Hash.new(0)

      @grades.each do |g|
        @days.each do |day|
          date_s = day.to_s
          b = g.breakdowns[date_s]

          @_totals[:coverage] += g.coverages[date_s].sum / 2
          @_totals[:visits]   += g.location_plan.visits[date_s].sum
          @_totals[:seen]     += b['seen'].sum
          @_totals[:queue]    += b['queue'].sum
          @_totals[:turbo]    += b['turbo'].sum
          @_totals[:penalty]  += b['penalties'].sum # Would b['penalty'] be faster? -RB
          s = b['slack'].sum
          @_totals[:slack]    += s
          @_totals[:wasted_time] += s * 60.0 / g.location_plan.normal[1].to_f # in minutes
          @_totals[:wasted_time] += g.over_staffing_wasted_mins(date_s) if g.over_staffed?(date_s) # in minutes
        end
      end

      @_totals
    end
  end

  def self.assign_letter(score)
    LETTERS.each do |letter, num|
      return letter if score >= num
    end

    return "A+"
  end

end
