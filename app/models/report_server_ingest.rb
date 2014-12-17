class ReportServerIngest < ActiveRecord::Base
  validates :end_date, presence: true
  validates :start_date, presence: true
  validates :data, presence: true

  has_many :heatmaps

end

