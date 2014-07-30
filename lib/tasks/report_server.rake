desc "This task is called by the Heroku scheduler add-on"
task :report_server_ingest => :environment do

  # Look back three months + 1 week
  # TODO: Make this configurable
  start_date = (Date.today << 3 ) - 7 
  # Always wait a week before pulling data so it can settle
  end_date = Date.today - 7

  # FIXME: For testing purposes only- waiting for an issue with the server to be fixed.
  #start_date = Date.parse('2014-05-01')
  #end_date = Date.parse('2014-06-30')
  puts start_date
  puts end_date
  importer = VolumeHistoryImporter.new(start_date, end_date, 'ALL')

  importer.authenticate!

  data = importer.fetch_data!

  ingest = ReportServerIngest.new
  ingest.start_date = start_date
  ingest.end_date = end_date
  ingest.data = data

  z0 = Zone.find_or_create_by(name: 'Unassigned')
  heatmaps = ingest.create_heatmaps!(30)
  heatmaps.each do |name, heatmap|
    begin
      location = Location.find_by!(uid: heatmap.uid)
    rescue ActiveRecord::RecordNotFound
      # Create new locations in the Unassigned zone if we haven't heard of this UID before.
       location = z0.locations.build(name: name, report_server_id: name.gsub(' ', '_'), max_mds: 3,  
                                     rooms: 12, open_times: [9,8,8,8,8,8,9], 
                                     close_times: [21,22,22,22,22,22,21], uid: heatmap.uid)
       location.speeds.build(doctors: 1, normal: 4, max: 6)
       location.speeds.build(doctors: 2, normal: 8, max: 12) 
       location.speeds.build(doctors: 3, normal: 12, max: 18) 
       location.speeds.build(doctors: 4, normal: 16, max: 24) 
       location.speeds.build(doctors: 5, normal: 20, max: 30) 
       location.save!
    end

    heatmap.save!
  end

  ingest.save!
end

task :report_server_dump => :environment do
  ingest = ReportServerIngest.last
  puts ingest.id
  puts ingest.start_date
  puts ingest.end_date
  puts ingest.totals
  puts ingest.data
end

task :heatmap_dump => :environment do
  maps = Heatmap.all
  maps.each do |heatmap| 
    puts heatmap.uid
    puts heatmap.get_days
  end
end

task :location_dump => :environment do
  locs = Location.all
  locs.each do |location|
    puts location.name
    puts location.uid
  end
end

