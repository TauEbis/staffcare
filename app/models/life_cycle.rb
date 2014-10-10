class LifeCycle < ActiveRecord::Base
  has_many :location_plans

  MAX_LENGTH = 10 * 60 * 60 # 10 hours in seconds

  OPTION_VALUES = {
    limit_1: 0,
    limit_1_5: 1,
    limit_2: 2,
    ratio_1: 3,
    ratio_1_5: 4,
    ratio_2: 5
  }.freeze

  OPTIONS = OPTION_VALUES.keys.freeze

  OPTION_NAMES = [
    'Limit 1',
    'Limit 1.5',
    'Limit 2',
    'Ratio 1',
    'Ratio 1.5',
    'Ratio 2'
  ].zip(0..OPTIONS.length).freeze

  # Maybe should do OPTIONS.keys, but maybe we'll remove some, so for now...
  # enum scribe_policy: [:limit_1, :limit_1_5, :limit_2, :ratio_1, :ratio_1_5, :ratio_2]
  # enum pcr_policy:    [:limit_1, :limit_1_5, :limit_2, :ratio_1, :ratio_1_5, :ratio_2]
  # enum ma_policy:     [:limit_1, :limit_1_5, :limit_2, :ratio_1, :ratio_1_5, :ratio_2]
  # enum xray_policy:   [:limit_1, :limit_1_5, :limit_2, :ratio_1, :ratio_1_5, :ratio_2]
  # enum am_policy:     [:limit_1, :limit_1_5, :limit_2, :ratio_1, :ratio_1_5, :ratio_2]
  # Manager is fixed 50 hours per week

  # Returns the symbol (e.g. :limit_1) for a given policy like :scribe_policy
  # by converting the DB stored integer into the symbol
  def policy(key)
    OPTIONS[send(key)]
  end

  def policy_name(key)
    OPTION_NAMES[send(key)][0]
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
    generate_1(starts, ends) * 2
  end

  def self.generate_1_5(starts, ends)
    twenty_five_percent = (ends - starts) / 4
    [
      Shift.new(starts_at: starts, ends_at: (ends - twenty_five_percent).round(30.minutes)),
      Shift.new(starts_at: (starts + twenty_five_percent).round(30.minutes), ends_at: ends)
    ]
  end

end
