class ReportServerIngest < ActiveRecord::Base
  validates :end_date, presence: true
  validates :start_date, presence: true
  validates :data, presence: true

  after_initialize :init

  def init
    @locations = {}
    @totals = {}
  end

  def add_record(loc_name, uid, dow, hour, count)
    if !@locations.has_key?(loc_name)
      @locations[loc_name] = IngestRecord.new(loc_name, uid)
      @totals[loc_name] = 0.0
    end

    # Note that the VisitDay is indexed for Sunday = 1, not 0
    @locations[loc_name].add_block(dow - 1, hour, count)
    @totals[loc_name] += count.to_f
  end

  def get_record(loc_name)
    return @locations[loc_name]
  end

  def create_heatmaps!(granularity)
    heatmaps = Hash.new
    records = JSON.parse(self.data)
    records.each do |record|
       self.add_record(record['Name'], record['ServiceSiteUid'],
                       record['VisitDay'], record['VisitHour'], record['VisitCount'])
    end

    @locations.each do |location, record|
      heatmap = Heatmap.where(uid: record.uid).first_or_initialize
      if granularity == 15
        Date::DAYNAMES.each do |day|
          record.days[day].keys.sort.each do |hour|
            heatmap.set(day, hour, record.get_visits(day, hour) / record.total_visits)
          end
        end
      elsif granularity == 30
        Date::DAYNAMES.each do |day|
          hours = record.days[day].keys.sort.each_slice(2) do |hour1, hour2|
            total = record.days[day][hour1] + record.days[day][hour2]
            heatmap.set(day, hour1, total / record.total_visits)
          end
        end
      end
      heatmaps[record.name] = heatmap
    end
    return heatmaps
  end


end

