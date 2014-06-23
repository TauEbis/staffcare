class SpeedyCoverageOptionsLoader

	def initialize
		@loaded_coverage_options = Hash.new
	end

	def load(location, day)
		coverage_options = location.coverage_options(day)
		key = coverage_options.opts_key

		if !@loaded_coverage_options.has_key?(key)
			coverage_options.build_list
			@loaded_coverage_options[:key] = coverage_options
		end

		@loaded_coverage_options[:key].list

	end
end