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

    at 25, "Storing new history data..."
    data.each do |record|
    end

    at 75, "Calculating heatmaps..."


    at 100, "Local volume records updated."
  end
end
