class CoverageShiftSetListLoader

	def initialize
		@ss_lists = Hash.new
	end

	def load(location, day)
		shift_set_list = location.create_shift_set_list(day)
		key = shift_set_list.opts_key

		if !@ss_lists.has_key?(key)
			shift_set_list.build_list
			@ss_lists[:key] = shift_set_list
		end

		@ss_lists[:key].list

	end
end