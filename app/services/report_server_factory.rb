class ReportServerFactory

  def initialize(opts={})
    @start_date = opts[:start_date] || (Date.today << 3 ) - 7     # Look back three months + 1 week
    @end_date   = opts[:end_date]   || Date.today - 7             # Always wait a week before pulling data so it can settle
    @uids       = opts[:uids]       || 'ALL'
    @data       = opts[:data]       || fetch_data(opts)
  end

  def import!
    ReportServerIngestor.new(@start_date, @end_date, @data).ingest!
  end

  private

    def fetch_data(opts)
      @fetcher   = opts[:fetcher]   || ReportServerFetcher.new(@start_date, @end_date, @uids)
      @fetcher.fetch_data!
    end
end