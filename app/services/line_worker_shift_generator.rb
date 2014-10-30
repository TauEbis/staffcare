class LineWorkerShiftGenerator
  MAX_LENGTH = 10 * 60 * 60 # 10 hours in seconds

  def initialize(location_plan)
    @location_plan = location_plan
    @grade = location_plan.chosen_grade

    @lines = Position.where.not(key: ['manager', 'md', nil])
  end


  def self.generate_shifts(policy, starts, ends)
    case policy
      when :limit_1, :ratio_1
        generate_1(starts, ends)
      when :limit_2, :ratio_2
        generate_2(starts, ends)
      when :limit_1_5, :ratio_1_5
        generate_1_5(starts, ends)
    end
  end

  def self.generate_1(starts, ends)
    if ends - starts > MAX_LENGTH
      mid = (starts + (ends - starts) / 2).round(30.minutes)
      [Shift.new(starts_at: starts, ends_at:  mid), Shift.new(starts_at: mid, ends_at: ends)]
    else
      [Shift.new(starts_at: starts, ends_at: ends)]
    end
  end

  def self.generate_2(starts, ends)
    shifts = generate_1(starts, ends)
    shifts.map{|s| [s, s.dup] }.flatten
  end

  def self.generate_1_5(starts, ends)
    twenty_five_percent = (ends - starts) / 4
    [
      Shift.new(starts_at: starts, ends_at: (ends - twenty_five_percent).round(30.minutes)),
      Shift.new(starts_at: (starts + twenty_five_percent).round(30.minutes), ends_at: ends)
    ]
  end

  def create!
    clear_old_shifts!

    # TODO: Assert that we have the values from the lifecycle or preferences

    @lines.each do |position|
      policy = policy_for_line(position)

      if [:limit_1, :limit_1_5, :limit_2].include?(policy)
        # Day-based, so let's use the open/close time
        @location_plan.schedule.days.each do |day|
          starts = day.in_time_zone(Shift::TZ).change(hour: @location_plan.open_times[day.wday])
          ends   = day.in_time_zone(Shift::TZ).change(hour: @location_plan.close_times[day.wday])
          new_shifts = self.class.generate_shifts(policy, starts, ends)
          save_shifts(new_shifts, position)
        end
      else
        # Per-doctor shift
        @grade.shifts.md.each do |shift|
          new_shifts = self.class.generate_shifts(policy, shift.starts_at, shift.ends_at)
          save_shifts(new_shifts, position)
        end
      end

    end
  end

  private

    def clear_old_shifts!
      @grade.shifts.not_md.delete_all
    end

    def policy_for_line(position)
      LifeCycle::OPTIONS[@location_plan.send("#{position.key}_policy")] # e.g. :limit_1
    end

    def save_shifts(new_shifts, position)
      new_shifts.each do |s|
      s.grade = @grade
      s.position = position
      s.save!
      end
    end

end
