class Visit < ActiveRecord::Base
  belongs_to :location
  belongs_to :report_server_ingest

  validates :granularity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 60 }
  validates :dow, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }
  validates :volumes, presence: true
  validate :valid_volumes

  scope :for_date_range, -> (start_date, end_date) { where("date >= ? AND date <= ?", start_date, end_date) }
  scope :ordered, -> { order(date: :asc, id: :desc) }
  default_scope -> { ordered }

  def valid_volumes
    unless volumes && !volumes.empty?
      errors.add(:base, "Please add valid historical visits.")
      return
    end
    volumes.each do |k, v|
      unless !v.nil? && v >= 0
        errors.add(:base, "Please add valid historical visits.")
        return
      end
    end
  end

  def total
    volumes.values.sum
  end

  def self.date_range
    Visit.ordered.first.date..Visit.ordered.last.date
  end

  def self.totals_by_date_by_location(start_date=nil, end_date=nil)
    visits = (start_date.nil? || end_date.nil?) ? Visit.includes(:location).all : Visit.includes(:location).for_date_range(start_date, end_date)

    totals = {}

    visits.each do |visit|
      totals[visit.date.to_s] ||= {}
      totals[visit.date.to_s][visit.location.id] = { total: visit.total, v_id: visit.id }
    end

    totals
  end

end
