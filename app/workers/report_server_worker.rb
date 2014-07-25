class ReportServerWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(start_date, end_date)
    at 0, "Beginning"

    importer = VolumeHistoryImporter.new(start_date, end_date, 'ALL')

    at 5, "Authenticating..."
    importer.authenticate!

    at 10, "Fetching history data..."
    data = importer.fetch_data!

    ingest = ReportServerIngest.new(start_date, end_date)
    at 25, "Processing new history data..."
    data.each do |record|
      ingest.add_record(record.Name, record.VisitDay, record.VisitHour, record.VisitCount)
    end

    at 50, "Calculating heatmaps..."
    ingest.create_heatmaps!(30)

    at 75, "Storing to the database..."
    ingest.save


    at 100, "Local volume records updated."
  end
end
