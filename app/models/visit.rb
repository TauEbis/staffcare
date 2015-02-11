class Visit < ActiveRecord::Base
  belongs_to :location
  belongs_to :report_server_ingest

  validates :granularity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 60 }
  validates :dow, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }
  validates :volumes, presence: true
  validates :date, presence: true, uniqueness: { scope: :location }
  validate :valid_volumes

  scope :for_date_range, -> (range) { where arel_table[:date].in(range) }
  scope :for_date_range_and_location, -> (range, location) { where arel_table[:date].in(range).and(arel_table[:location_id].eq(location.id)) }
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
    @_total ||= volumes.values.sum
  end

  def in_chunks(chunks)
    chunked_totals = []
    num_of_keys = volumes.keys.size
    step = num_of_keys / chunks

    (0..(chunks-1)).each do |chunk|
      chunk_keys = volumes.keys[(chunk*step..chunk*step+step-1)]
      chunk_keys = volumes.keys[(chunk*step..-1)] if chunk == chunks-1
      chunk_total = volumes.select{ |k,v| chunk_keys.include?(k) }.values.sum
      chunked_totals << chunk_total
    end

    chunked_totals
  end

# Two class methods for preparing data for VisitsController index action
  def self.date_range
    Visit.ordered.first.date..Visit.ordered.last.date
  end

  def self.totals_by_date_by_location(range=nil)
    visits = range.nil? ? Visit.includes(:location).all : Visit.includes(:location).for_date_range(range)

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
        if date_totals = totals_by_date_by_location(date..date)[date.to_s]
          location_rows = location_ids.map do |l_id|
            (l_total = date_totals[l_id]) ? l_total[:total] : ''
          end
        else
          location_rows = []
        end

        row = attribute_rows + location_rows
        csv << row
      end

    end
  end

end
