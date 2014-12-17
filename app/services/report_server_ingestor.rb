# A service that ingests data from report server. Saves it in an ingest record,
# and creates/updates other records that depend on report server data.
class ReportServerIngestor

  def initialize(start_date, end_date, data)
    @start_date = start_date
    @end_date = end_date
    @data = data
    @locations_hash = {}
  end

  def ingest!
    create_ingest!
    hash_data_by_location
    create_locations!
    create_heatmaps!(30)
  end

  def create_ingest!
    @ingest = ReportServerIngest.create(start_date: @start_date, end_date: @end_date, data: @data)
  end

  def hash_data_by_location
    @data.each do |el|
      loc_name = el['Name']
      dow = el['VisitDay'] - 1        # Note that the VisitDay is indexed for Sunday = 1, not 0
      hour = el['VisitHour']
      count = el['VisitCount']
      @locations_hash[loc_name] ||= {}
      @locations_hash[loc_name][:uid] ||= el['ServiceSiteUid']
      @locations_hash[loc_name][:day_volumes] ||= {}
      @locations_hash[loc_name][:day_volumes][Date::DAYNAMES[dow.to_i]] ||= {}
      @locations_hash[loc_name][:day_volumes][Date::DAYNAMES[dow.to_i]][hour] = count.to_f
    end
  end

  def create_locations!
    @locations_hash.each do |name, loc_data|
      # Create new locations if we haven't heard of this UID before.
      Location.create_default( name, {uid: loc_data[:uid]} ) if !Location.find_by(uid: loc_data[:uid])
    end
  end

  def create_heatmaps!(granularity=30)
    @locations_hash.values.each do |loc_data|
      heatmap = Heatmap.where(uid: loc_data[:uid]).first_or_initialize
      heatmap.recalc_from_volumes(loc_data[:day_volumes], granularity)
      @ingest.heatmaps << heatmap
      heatmap.save!
    end
  end

end
