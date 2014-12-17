desc "Manual report server information ingest"
task :rs_ingest => :environment do
  ReportServerFactory.new.import!
end

desc "Loading dummy data"
task :rs_load => :environment do
  start_date = Date.parse('2014-05-08')
  end_date = Date.parse('2014-08-08')
  data = JSON.parse( File.read('mock_data/rs_data.json') )

  ReportServerFactory.new(start_date: start_date, end_date: end_date, data: data).import!
end

task :report_server_dump => :environment do
  ingest = ReportServerIngest.last
  puts ingest.id
  puts ingest.start_date
  puts ingest.end_date
  puts ingest.data
end

# Not really report server related
task :heatmap_dump => :environment do
  maps = Heatmap.all
  maps.each do |heatmap|
    puts heatmap.uid
    puts heatmap.days
  end
end

task :location_dump => :environment do
  locs = Location.all
  locs.each do |location|
    puts location.name
    puts location.uid
  end
end