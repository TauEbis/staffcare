class ReportServerFactory

  WEEKS_TO_WAIT = 1 # Weeks to wait before pulling data

  def initialize(opts={})
    @uids     = opts[:uids] || 'ALL'
    @ingestor = opts[:ingestor] || ReportServerIngestor.new
    @fetcher  = opts[:fetcher]  || ReportServerFetcher.new
  end

  def scheduled_import!
    start_date = Location.date_of_first_missing_visit || default_start_date
    start_date = to_sunday(start_date)
    start_date = [ start_date, default_start_date ].min       # Make sure start_date isn't in the future

    default_start_date == start_date ? week_import! : bulk_import!(first_sunday: start_date)
  end

  def week_import!(opts={})
    start_date    = opts[:start_date] || default_start_date
    end_date      = start_date + 6
    data          = opts[:data] || @fetcher.fetch_data!(start_date, end_date, @uids)
    calc_heatmaps = opts[:cacl_heatmaps] || true

    @ingestor.ingest!(start_date, end_date, data, calc_heatmaps)
  end

  def bulk_import!(opts={})
    first_sunday = opts[:first_sunday] || Date.parse('2013-01-01')
    first_sunday = to_sunday(first_sunday)
    last_sunday  = opts[:last_sunday] || default_start_date
    last_sunday  = to_sunday(last_sunday)
    weeks        = (last_sunday - first_sunday).to_i / 7

    (0..weeks).each do |n|
      w_opts = { start_date: first_sunday + 7*n, calc_heatmaps: (n == weeks) }
      if opts[:data_set] # An array of raw json representing each weeks data
        w_opts[:data] = opts[:data_set][n]
      end
      week_import!(w_opts)
    end
  end

  private

    def default_start_date
      @_def_start ||= to_sunday(Date.today) - WEEKS_TO_WAIT * 7
    end

    def default_end_date
      @_def_end ||= default_start_date + 6
    end

    def to_sunday(date)
      date - date.wday
    end

end