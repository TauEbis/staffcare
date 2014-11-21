require 'spec_helper'

describe SolutionSetBuilder, :type => :service do

	let(:builder) 			{ SolutionSetBuilder.new }

	describe "building a simple solution set" do

		before do
			options = {open: 8, close: 22, max_mds: 1, min_openers: 1, min_closers: 1}
			builder.setup(options)
		end

		it "should return single coverage" do
			expect(builder.build).to eq([Array.new(28,1)])
		end
	end

	describe "building a simple solution set" do

		before do
			options = {open: 8, close: 22, max_mds: 2, min_openers: 2, min_closers: 2}
			builder.setup(options)
		end

		it "should return double coverage" do
			expect(builder.build).to eq([Array.new(28,2)])
		end
	end

	describe "building a simple solution set" do

		before do
			options = {open: 8, close: 22, max_mds: 2, min_openers: 2, min_closers: 1}
			builder.setup(options)
		end

		it "should return the correct tiered coverage" do
			expected = (0..7).map { |x| Array.new(28-2*x,2) + Array.new(2*x,1) }.reverse
			expect(builder.build).to eq(expected)
		end
	end

# Sanity testing private methods
	describe "#expand_coverage" do
		before do
			options = {open: 8, close: 22, max_mds: 3, min_openers: 1, min_closers: 1}
			builder.setup(options)
		end

		it "correctly expands the terse coverage representation" do
			terse = [8, 9, 14, 19, 21, 22]
			expanded = Array.new(2,1) + Array.new(10,2) + Array.new(10,3) + Array.new(4,2) + Array.new(2,1)
			actual = builder.send(:expand_coverage, terse)
			expect(actual).to eq(expanded)
		end

	end

	describe "#valid" do
		before do
			options = {open: 8, close: 22, max_mds: 3, min_openers: 1, min_closers: 1}
			builder.setup(options)
		end

		it "valid shifts should return true" do
			valid_shift = [8, 8, 8, 22, 22, 22]
			actual = builder.send(:valid?, valid_shift)
			expect(actual).to be(true)
		end

		it "invalid shifts should return false" do
			invalid_shift = [8, 14, 14, 16, 16, 22]
			actual = builder.send(:valid?, invalid_shift)
			expect(actual).to be(false)
		end

		it "invalid shifts should return false" do
			invalid_shift = [15, 15, 15, 15, 15, 15]
			actual = builder.send(:valid?, invalid_shift)
			expect(actual).to be(false)
		end
	end

	describe "#midday_pairs" do
		before do
			options = {open: 8, close: 22, max_mds: 3, min_openers: 1, min_closers: 1}
			builder.setup(options)
		end

		it "has zero pairs" do
			no_pairs = [8, 9, 14, 19, 21, 22]
			actual = builder.send(:midday_pairs, no_pairs)
			expect(actual).to eq(0)
		end

		it "has one pair" do
			one_pair = [8, 15, 15, 15, 22, 22]
			actual = builder.send(:midday_pairs, one_pair)
			expect(actual).to eq(1)
		end

		it "has two pairs" do
			two_pairs = [8, 15, 15, 15, 15, 22]
			actual = builder.send(:midday_pairs, two_pairs)
			expect(actual).to eq(2)
		end

	end

end