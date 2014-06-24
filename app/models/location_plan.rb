class LocationPlan < ActiveRecord::Base
  belongs_to :location
  belongs_to :schedule

  has_many :grades, dependent: :destroy

  attr_reader :solution_set

  OPTIMIZER_FIELDS = [:max_mds, :rooms, :min_openers, :min_closers, :open_times, :close_times]

  def solution_set
    @_solution_set ||= build_solution_set
  end

  def get_solution_set_for_builder
    @_solution_set
  end

  def build_solution_set
    SolutionSetBuilder.new.build(self)
  end

  def opts_key
    self.attributes.slice(*OPTIMIZER_FIELDS).to_s
  end

  def hours_open
    @close - @open # half hours in the day
  end

  def min_shift
    hours_open / 2 # shortest allowable shift
  end

  def fixed_openers
    @fixed_openers ||= Array.new(min_openers, @open) # Fixed openers
  end

  def fixed_closers
    @fixed_closers ||= Array.new(min_closers, @close) # Fixed closers
  end

  def first_possible_close
    @open + min_shift # first time to end a shift
  end

  def last_possible_open
    @close - min_shift # last time to start a shift
  end

  def openings
    last_possible_open - @open + 1 # number of possible shift opens -- equal to @closings
  end

  def	closings
    @close - first_possible_close + 1 # number of possible shift closes -- equal to @openings
  end

  def midday
    @open + hours_open / 2 # midday shift which happens to also be the only time shifts can both start and stop
  end

  def openers_to_assign
    max_mds - min_openers
  end

  def closers_to_assign
    max_mds - min_closers
  end

  def full_coverage
    Array.new(set_size/2, @open) + Array.new(set_size/2, @close)
  end

  def set_size
    max_mds * 2
  end

  # TODO: set_size is the number of elements in a shift set.
  # It is twice max_mds, because minshift is half the working day.
  # Further explanation given on readme.
end
