class LineWorkerShiftGenerator
  MAX_LENGTH = 10 * 60 * 60 # 10 hours in seconds

  def initialize(grade)
    @grade = grade
    @rules = grade.rules.line_workers
  end


  def self.generate_shifts(policy, starts, ends, opts={})
    case policy
      when :limit_1, :ratio_1
        generate_1(starts, ends)
      when :limit_2, :ratio_2
        generate_2(starts, ends)
      when :limit_1_5, :ratio_1_5
        generate_1_5(starts, ends)
      when :salary
        generate_salary(starts, ends, opts[:ftes], opts[:dow], opts[:pos])
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
    shifts.flat_map{|s| [s, s.dup]}
  end

  def self.generate_1_5(starts, ends)
    twenty_five_percent = (ends - starts) / 4
    [
      Shift.new(starts_at: starts, ends_at: (ends - twenty_five_percent).round(30.minutes)),
      Shift.new(starts_at: (starts + twenty_five_percent).round(30.minutes), ends_at: ends)
    ]
  end

 def self.generate_salary(starts, ends, ftes, dow, pos)
  # dow 0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday

    mid = starts + ((ends-starts)/2).seconds

    salary_shifts=
      {
        2 =>
        {
          0 =>  { manager: [ {starts_at: starts, ends_at: ends} ],            am: [                                    ] },
          1 =>  { manager: [ {starts_at: starts, ends_at: ends} ],            am: [                                    ] },
          2 =>  { manager: [ {starts_at: starts, ends_at: ends} ],            am: [                                    ] },
          3 =>  { manager: [ {starts_at: starts, ends_at: mid } ],            am: [ {starts_at: mid,    ends_at: ends} ] },
          4 =>  { manager: [                                    ],            am: [ {starts_at: starts, ends_at: ends} ] },
          5 =>  { manager: [                                    ],            am: [ {starts_at: starts, ends_at: ends} ] },
          6 =>  { manager: [                                    ],            am: [ {starts_at: starts, ends_at: ends} ] }
        },
        3 =>
        {
          0 =>  { manager: [                                              ],  am: [ {starts_at: starts,        ends_at: ends} ] },
          1 =>  { manager: [ {starts_at: starts, ends_at: starts+8.hours} ],  am: [ {starts_at: ends-10.hours, ends_at: ends} ] },
          2 =>  { manager: [ {starts_at: starts, ends_at: starts+8.hours} ],  am: [ {starts_at: ends-10.hours, ends_at: ends} ] },
          3 =>  { manager: [ {starts_at: starts, ends_at: starts+8.hours} ],  am: [ {starts_at: ends-10.hours, ends_at: ends} ] },
          4 =>  { manager: [ {starts_at: starts, ends_at: starts+8.hours} ],  am: [ {starts_at: ends-10.hours, ends_at: ends} ] },
          5 =>  { manager: [ {starts_at: starts, ends_at: starts+8.hours} ],  am: [ {starts_at: ends-10.hours, ends_at: ends} ] },
          6 =>  { manager: [                                              ],  am: [ {starts_at: starts,        ends_at: ends} ] }
        }
      }

    salary_shifts[ftes][dow][pos].map do |salary_shift|
      Shift.new( starts_at: [salary_shift[:starts_at], starts].max, ends_at: [salary_shift[:ends_at], ends].min )
    end

  end

  def create!
    clear_old_shifts!

    # TODO: Assert that we have the values from the rules

    days=@grade.days
    open_times=@grade.open_times
    close_times=@grade.close_times
    ftes=@grade.ftes

    @rules.each do | rule |

      policy = rule.name.to_sym
      key = rule.position.key.to_sym
      new_shifts = []

      case policy
        when :limit_1, :limit_1_5, :limit_2, :salary
          # Day-based, so let's use the open/close time
          days.each do |day|
            starts = day.in_time_zone(Shift::TZ).change(hour: open_times[day.wday])
            ends   = day.in_time_zone(Shift::TZ).change(hour: close_times[day.wday])
            new_shifts += self.class.generate_shifts(policy, starts, ends, {ftes: ftes, dow: day.wday, pos: key})
          end
        else
          # Per-doctor shift
          @grade.shifts.md.each do |shift|
            new_shifts += self.class.generate_shifts(policy, shift.starts_at, shift.ends_at)
          end
        end
      save_shifts(new_shifts, rule.position) unless new_shifts.empty?

    end
  end

  private

    def clear_old_shifts!
      @grade.shifts.not_md.delete_all
    end

    def save_shifts(new_shifts, position)
      new_shifts.each do |s|
        s.grade = @grade
        s.position = position
        s.save!
      end
    end

end
