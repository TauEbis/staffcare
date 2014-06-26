class LocationPlan < ActiveRecord::Base
  belongs_to :location
  belongs_to :schedule
  belongs_to :visit_projection

  has_many :grades, dependent: :destroy
  belongs_to :chosen_grade

  OPTIMIZER_FIELDS = [:max_mds, :rooms, :min_openers, :min_closers, :open_times, :close_times]

  def solution_set_options(day)
    {open: open_times[day.wday()], close: close_times[day.wday()], max_mds: max_mds, min_openers: min_openers, min_closers: min_closers}
  end

  def build_solution_set(day)
    SolutionSetBuilder.new(self, day).build
  end
end
