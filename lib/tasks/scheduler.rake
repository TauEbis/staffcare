desc "This task is called by the Heroku scheduler add-on"
task :report_server_ingest => :environment do

  # Look back three months + 1 week
  # TODO: Make this configurable
  start_date = (Date.today << 3 ) - 7 
  puts start_date
  # Always wait a week before pulling data so it can settle
  end_date = Date.today - 7
  puts end_date
  start_date = Date.parse('2014-07-01')
  end_date = start_date
  importer = VolumeHistoryImporter.new(start_date, end_date, 'ALL')

  importer.authenticate!

  data = importer.fetch_data!

  ingest = ReportServerIngest.new
  ingest.start_date = start_date
  ingest.end_date = end_date
  data.each do |record|
    ingest.add_record(record['Name'], record['VisitDay'], record['VisitHour'], record['VisitCount'])
  end 

  ingest.create_heatmaps!(30)

  ingest.save!
end

task :report_server_dump => :environment do
  ingest = ReportServerIngest.last
  records = IngestRecord.find_by report_server_ingest_id: ingest.id
  puts records
end


