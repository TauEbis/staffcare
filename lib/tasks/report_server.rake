namespace :rs do

  desc "Load last week's visits"
  task :week_visit_import => :environment do
    ReportServerFactory.new.week_import!
    ShortForecast.build_latest!
  end

  desc "Load visits from 2013 to present"
  task :bulk_visit_import => :environment do
    ReportServerFactory.new.bulk_import!
    ShortForecast.build_latest!
  end

  desc "Loading dummy data"
  task :dummy_visit_import => :environment do
    first_sunday = Date.parse('2012-12-30')
    last_sunday = Date.parse('2015-02-08')

    data_set = []
    File.open('mock_data/ingest_data.dump', 'r').each_line do |line|
      data_set << JSON.parse(line)
    end

    ReportServerFactory.new.bulk_import!(first_sunday: first_sunday, last_sunday: last_sunday, data_set: data_set)
  end

  desc "Dumping dummy data"
  task :dump_ingest_data => :environment do
    File.open("mock_data/ingest_data.dump", "w+") do |f|
      ingest_ids = Visit.ordered.pluck(:report_server_ingest_id).uniq
      ingest_ids.each do |ingest_id|
        f << ReportServerIngest.find(ingest_id).data.to_json + "\n"
      end
    end
  end

  task :last_ingest_dump => :environment do
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
      puts heatmap.location.uid
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

end