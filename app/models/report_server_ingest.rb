class ReportServerIngest < ActiveRecord::Base
  validates :end_date, presence: true
  validates :start_date, presence: true
  validates :locations, presence:true
  validates :heatmaps, presence: true
  validates :totals, presence: true

  after_initialize :init
  has_many :ingest_records
  validates_associated :ingest_records
  has_many :heatmaps
  validates_associated :heatmaps

  attr_accessor :totals, :locations, :heatmaps

  def init
    @locations = {}
    @heatmaps = {}
    @totals = {}
  end

  def add_record(loc_name, dow, hour, count)
    if !@locations.has_key?(loc_name)
      @locations[loc_name] = IngestRecord.new
      @locations[loc_name].name = loc_name
      @totals[loc_name] = 0.0
    end

    @locations[loc_name].add_block(dow, hour, count)
    @totals[loc_name] += count.to_f
  end

  def get_record(loc_name)
    return @locations[loc_name]
  end

  def create_heatmaps!(granularity)
    @locations.each do |location, record|
      heatmap = Heatmap.new
      heatmap.name = location
      if granularity == 15 
        Date::DAYNAMES.each do |day|
          record.get_day(day).keys.sort.each do |hour|
            heatmap.set(day, hour, record.get_visits(day, hour) / record.total_visits)
          end
        end
      elsif granularity == 30
        Date::DAYNAMES.each do |day|
          hours = record.get_day(day).keys.sort.each_slice(2) do |hour1, hour2| 
            total = record.get_visits(day, hour1) + record.get_visits(day, hour2)
            heatmap.set(day, hour1, total / record.total_visits)
          end
        end
      end
      @heatmaps[record.name] = heatmap
    end
  end


end

