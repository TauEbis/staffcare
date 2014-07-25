class ReportServerIngest < ActiveRecord::Base
  has_many :ingest_record

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
    @locations = {}
    @heatmaps = {}
    @totals = {}

  end

  def add_record(loc_name, dow, hour, count)
    if !@locations.has_key?(loc_name)
      @locations[loc_name] = IngestRecord.new(loc_name)
      @totals[loc_name] = 0.0
    end

    @locations[loc_name].add_block(dow, hour, count)
    @totals[loc_name] += count.to_f
  end
  
  def create_heatmaps!(granularity)
    @locations.each do |record|
      heatmap = Heatmap.new(record.name)
      if granularity == 15 
        Date::DAYNAMES.each do |day|
          record.get_day(day).keys.sorted.each do |hour|
            heatmap.set(day, hour, record.get_visits(day, hour) / record.total_visits)
          end
        end
      elsif granularity == 30
        hours = record.get_day(day).keys.sorted.each do |hour1, hour2| 
          total = record.get_visits(day, hour1) + record.get_visits(day, hour2)
          heatmap.set(day, hour1, total / record.total_visits)
        end
      end
      @heatmaps[record.name] = heatmap
    end
  end


end

