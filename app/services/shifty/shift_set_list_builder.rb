class ShiftSetListBuilder

	def build(shift_set_list)
		@list = shift_set_list
		@open = @list.open
		@close = @list.close
		@max_mds = @list.max_mds
		@min_openers = @list.min_openers
		@min_closers = @list.min_closers

		@sets = @list.get_list_for_builder

		build_valid_shift_sets
		@list
	end

	private

		def build_valid_shift_sets

			combinations = (1..(@list.openings + @list.openers_to_assign - 1 )).to_a.combination(@list.openers_to_assign).to_a

			combinations.each do |am_combos|
				am_steps = am_combos.map.with_index { |el, index | el + @list.open - (index + 1) }

				combinations.each do |pm_combos|
					pm_steps = pm_combos.map.with_index { |el, index | el + @list.first_possible_close - (index + 1) }
					steps = am_steps + pm_steps

					shifts = @list.fixed_openers + steps + @list.fixed_closers # eg add [8] at begining and [22] at the end

					if valid?(shifts, @list.min_shift)
						@sets<<shifts
					end

				end
			end
		end

		def valid?(shifts, min_shift) # checks to see if the open and close times in a shift are satisfiable given the @min_shift
			midday_pairs = midday_pairs(shifts)
			if (midday_pairs == set_size/2)
				return false
			else
				(0..(set_size/2 - midday_pairs -1)).each do |x|
					return false if (shifts[set_size/2 + midday_pairs + x] - shifts[x] < min_shift)
				end
			end
			return true
		end

		def midday_pairs(shifts) # this method returns how many pairs of redundant open close pairs exist at midday
			if shifts.index(@list.midday)
				midday_opens = [(set_size/2) - shifts.index(@list.midday), 0].max
				midday_closes = [shifts.rindex(@list.midday) - set_size/2 +1, 0].max
				midday_pairs = [midday_opens, midday_closes].min
			else
				0
			end
		end

		def set_size
			@list.set_size
		end
end
