# A service that ingests data from report server. Saves it in a ReportServerIngest,
# and creates/updates other records that depend on report server data.
class ReportServerIngestor

  def ingest!(start_date, end_date, data, calc_heatmaps=true)
    @start_date = start_date
    @end_date = end_date
    @data = data

    create_ingest!
    hash_data_by_location
    create_locations!
    create_visits!
    create_heatmaps! if calc_heatmaps
  end

  def create_ingest!
    @ingest = ReportServerIngest.create(start_date: @start_date, end_date: @end_date, data: @data)
  end

  def hash_data_by_location
    @locations_hash = {}
    @data.each do |el|
      loc_name = el['Name']
      dow = el['VisitDay'] - 1   # Note that the VisitDay is indexed for Sunday = 1, not 0, and does not contain a date.
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
      # Create new location if we haven't heard of this UID before.
      Location.create_default( name, {uid: loc_data[:uid]} ) if !Location.find_by(uid: loc_data[:uid])
    end
  end

  def create_visits!
    if (@end_date - @start_date).to_i == 6
      @locations_hash.values.each do |loc_data|
        loc_id = Location.find_by(uid: loc_data[:uid]).id
        loc_data[:day_volumes].each do |k,v|
          dow = Date::DAYNAMES.index(k)
          offset = (dow - @start_date.wday).modulo(7)
          date = @start_date + offset.days
          visit = Visit.where(location_id: loc_id, date: date).first_or_initialize
          visit.volumes = v
          visit.granularity = Time.parse(v.keys.second).min - Time.parse(v.keys.first).min
          visit.dow = dow
          @ingest.visits << visit
          visit.save!
        end
      end
    end
  end

  def create_heatmaps!
    @locations_hash.values.each do |loc_data|
      loc = Location.find_by(uid: loc_data[:uid])
      if loc.sufficient_data?
        heatmap = Heatmap.where(location_id: loc.id).first_or_initialize
        heatmap.recalc_from_volumes(loc.average_timeslot_volumes)
        @ingest.heatmaps << heatmap
        heatmap.save!
      end
    end
  end

end
