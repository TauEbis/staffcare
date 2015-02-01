class Visit < ActiveRecord::Base
  belongs_to :location
  belongs_to :report_server_ingest

  validates :granularity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 60 }
  validates :dow, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }
  validates :volumes, presence: true, uniqueness: { scope: [:location, :date] }
  validates :date, presence: true
  validate :valid_volumes

  scope :for_date_range, -> (start_date, end_date) { where("date >= ? AND date <= ?", start_date, end_date) }
  scope :ordered, -> { order(date: :asc, id: :desc) }
  default_scope -> { ordered }

# Custom Validation

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

# Class methods for preparing data for VisitsController index action

  def self.date_range
    Visit.ordered.first.date..Visit.ordered.last.date
  end

  def self.totals_by_date_by_location(start_date=nil, end_date=nil)
    visits = (start_date.nil? || end_date.nil?) ? Visit.includes(:location).all : Visit.includes(:location).for_date_range(start_date, end_date)

    totals = {}

    visits.each do |visit|
      totals[visit.date.to_s] ||= {}
      totals[visit.date.to_s][visit.location_id] = { total: visit.total, v_id: visit.id }
    end

    totals
  end

 # This class method is used to export visits
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      location_ids = Location.ordered.all.pluck(:id)
      attribute_columns = [ 'date' ]
      location_columns = Location.ordered.all.pluck(:upload_id)
      columns = attribute_columns + location_columns

      csv << columns

      date_range.each do |date|
        attribute_rows = [ date.to_s ]
        date_totals = totals_by_date_by_location(date, date)[date.to_s]
        location_rows = location_ids.map do |l_id|
          (l_total = date_totals[l_id]) ? l_total[:total] : ''
        end

        row = attribute_rows + location_rows
        csv << row
      end

    end
  end


end
