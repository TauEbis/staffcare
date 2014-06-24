class Grade < ActiveRecord::Base
  belongs_to :location_plan

  enum source: [:optimizer, :last_month, :manual]

end
