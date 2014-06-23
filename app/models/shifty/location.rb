class Location

	attr_reader :name, :max_mds, :open, :close

	def initialize(opts={})

		@name = opts[:name] # Site name
	  @max_mds = opts[:max_mds]  # Max mds who can work concurrently
		@rooms = opts[:rooms] # Not used yet
		@open = opts[:open] # Array of opening hour by day of the week
		@close = opts[:close] # Array of closing hour by day of the week

	end

# Eventually we may want to create a second coverage_options that is a (smaller) list of conceivable solutions not just all valid shifts
	def coverage_options(day)
		CoverageOptions.new(open: @open[day.wday()], close: @close[day.wday()], max_mds: @max_mds)
	end

	def to_sym
		@name.to_sym
	end

end