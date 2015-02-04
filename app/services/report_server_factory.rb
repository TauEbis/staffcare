class ReportServerFactory

  def initialize(opts={})
    @uids     = opts[:uids] || 'ALL'
    @ingestor = opts[:ingestor] || ReportServerIngestor.new
    @fetcher  = opts[:fetcher]  || ReportServerFetcher.new
  end

  def weekly_import!(opts={})
    start_date    = opts[:start_date] || Date.today - Date.today.wday - 5*7  # Look back 5 sundays from current sunday
    end_date      = start_date + 6
    data          = opts[:data] || @fetcher.fetch_data!(start_date, end_date, @uids)
    calc_heatmaps = opts[:cacl_heatmaps] || true

    @ingestor.ingest!(start_date, end_date, data, calc_heatmaps)
  end

  def bulk_import!(opts={})
    first_sunday = opts[:first_sunday] || Date.parse('2013-01-01')
    first_start  = first_sunday - first_sunday.wday                 # Make sure it's a sunday
    last_sunday  = opts[:last_sunday] || Date.today - 5*7           # Look back 5 sundays from current sunday
    last_start   = last_sunday - last_sunday.wday                   # Make sure it's a sunday
    weeks        = (last_start - first_start).to_i / 7

    (0..weeks).each do |n|
      w_opts = { start_date: first_start + 7*n, calc_heatmaps: (n == weeks) }
      if opts[:data_set] # An array of raw json representing each weeks data
        w_opts[:data] = opts[:data_set][n]
      end
      weekly_import!(w_opts)
    end
  end

end