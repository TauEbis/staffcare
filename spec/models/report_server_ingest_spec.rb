require 'spec_helper'

describe ReportServerIngest do
  let(:ingest) { ReportServerIngest.new(Date.parse('2014-07-01'), Date.parse('2014-07-01')) }
  let (:record) { IngestRecord.new('loc1') }
  subject { ingest }

# Attributes
  	it { should respond_to(:start_date) }
    it { should respond_to(:end_date) }
    it { should respond_to(:locations) }
    it { should respond_to(:heatmaps) }
    it { should respond_to(:totals) }
=begin
# Associations
    describe "zone association" do
      its(:zone) {should eq zone}
    end

# Validations
  	it { should be_valid }

  	context "when zone_id is not present" do
  		before { location.zone_id = nil }
  		it {should_not be_valid}
  	end

    context "when rooms is not present" do
      before { location.rooms = nil }
      it { should_not be_valid }
    end

  	context "when rooms is not numeric" do
			before { location.rooms = "a" }
			it { should_not be_valid }
  	end

    context "when rooms is too large" do
      before { location.rooms = 101 }
      it { should_not be_valid }
    end

    context "when rooms is too small" do
      before { location.rooms = -1 }
      it { should_not be_valid }
    end

    context "when max_mds is not present" do
      before { location.max_mds = nil }
      it { should_not be_valid }
    end

  	context "when max_mds is not numeric" do
			before { location.max_mds = "a" }
			it { should_not be_valid }
  	end

  	context "when max_mds is too large" do
			before { location.max_mds = 101 }
			it { should_not be_valid }
  	end

  	context "when max_mds is too small" do
			before { location.max_mds = -1 }
			it { should_not be_valid }
  	end

    context "when min_openers is not present" do
      before { location.min_openers = nil }
      it { should_not be_valid }
    end

    context "when min_openers is not numeric" do
      before { location.min_openers = "a" }
      it { should_not be_valid }
    end

    context "when min_openers is too small" do
      before { location.min_openers = -1 }
      it { should_not be_valid }
    end

    context "when min_openers is greater than max_mds" do
      before do
        location.min_openers = 2
        location.max_mds = 1
      end
      it { should_not be_valid }
    end

    context "when min_closers is not present" do
      before { location.min_closers = nil }
      it { should_not be_valid }
    end

    context "when min_closers is not numeric" do
      before { location.min_closers = "a" }
      it { should_not be_valid }
    end

    context "when min_closers is too small" do
      before { location.min_closers = -1 }
      it { should_not be_valid }
    end

    context "when min_closers is greater than max_mds" do
      before do
        location.min_closers = 2
        location.max_mds = 1
      end
      it { should_not be_valid }
    end

    day_params.each do |day_param|
      context "when #{day_param} is not present" do
        before { location.send("#{day_param}=", nil) }
        it { should_not be_valid }
      end
    end

    days.each do |day|
      context "when #{day}_open is after #{day}_close" do
        before do
          location.send("#{day}_open=", 1080)
          location.send("#{day}_close=", 720)
        end
        it { should_not be_valid }
      end
    end

# Scope
  describe "scope" do
    let!(:a_name) { FactoryGirl.create(:location, name: "Alfred_St", zone: zone) }
    let!(:z_name) { FactoryGirl.create(:location, name: "Zenith_St", zone: zone) }

    describe "ordered" do
      it "should be alphabetically ordered by name" do
        expect(Location.ordered.to_a).to eq [a_name, z_name]
      end
    end

    describe "default" do
      it "should be alphabetically ordered by name" do
        expect(Location.all.to_a).to eq [a_name, z_name]
      end
    end
  end

=end
# Methods
  describe "#add_record" do

    context "when a record is added to the ingest" do
      before { ingest.add_record('loc1', 0, "08:00:00", 5.0) }
      it "should add a record correctly" do
        expect(ingest.get_record('loc1').name).to eq 'loc1'
        expect(ingest.get_record('loc1').total_visits.to_i).to eq 5
      end
    end
  end

=begin
  describe "#close_times" do
    let(:closes_in_hours) do
      days.map { |day| location.send("#{day}_close") / 60 }
    end

    it "should return the day_close attibutes divided by 60" do
      expect(location.close_times).to eq closes_in_hours
    end
  end

  describe "#open_times=" do
    let(:opens_in_hours) { (6..12).to_a }
    let(:opens_in_minutes) { opens_in_hours.map { |hour| hour * 60 } }
    before { location.open_times = opens_in_hours }

    it "day_open attibutes should be set in minutes" do
      open_attributes = days.map { |day| location.send("#{day}_open") }
      expect(open_attributes).to eq opens_in_minutes
    end
  end

  describe "#close_times=" do
    let(:closes_in_hours) { (14..20).to_a }
    let(:closes_in_minutes) { closes_in_hours.map { |hour| hour * 60 } }
    before { location.close_times = closes_in_hours }

    it "day_close attibutes should be set in minutes" do
      close_attributes = days.map { |day| location.send("#{day}_close") }
      expect(close_attributes).to eq closes_in_minutes
    end
  end
=end
end
