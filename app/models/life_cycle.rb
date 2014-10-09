class LifeCycle < ActiveRecord::Base
  has_many :location_plans

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

end
