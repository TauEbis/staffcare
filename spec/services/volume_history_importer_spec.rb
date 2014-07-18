require 'spec_helper'

describe VolumeHistoryImporter, :type => :service do
  day = Date.parse('2014-07-01')
  let(:importer) { VolumeHistoryImporter.new(day, day, '414F0BD3-0460-405D-9136-0F16DB212BA9') }
  subject { importer }

# Attributes
  	it { should respond_to(:start_date) }
    it { should respond_to(:end_date) }
    it { should respond_to(:location) }
    it { should respond_to(:authenticate) }
    it { should respond_to(:fetch_data) }
    it { should respond_to(:authenticated?) }

# Environmental dependencies
    #
# Class methods
  describe "#valid_guid?" do
    it "should recognize legal guids" do
      expect(VolumeHistoryImporter.valid_guid?('414F0BD3-0460-405D-9136-0F16DB212BA9')).to be_truthy
    end
  end
    
# Instance Methods
  describe "#authenticated" do

    context "when authenticate() has not been called" do
      it "should return false if authenticate() hasn't run" do
        expect(importer.authenticated?).to eq false
      end
    end
  end

=begin
  2014-07-18: Blocked by IP connectivity issues.
  describe "#authenticate" do

    context "when a correct username and password are provided" do
      before { importer.authenticate() }
      it "should establish a session when authenticate() is called" do
        expect(importer.session_id).not_to be_nil
      end
    end
  end
=end


end
