require 'spec_helper'

describe VolumeHistoryImporter, :type => :service do
  day = Date.parse('2014-07-01')
  let(:importer) { VolumeHistoryImporter.new(day, day, '414F0BD3-0460-405D-9136-0F16DB212BA9') }
  let(:all_importer) { VolumeHistoryImporter.new(day, day, 'ALL') }
  subject { importer }

# Attributes
  	it { should respond_to(:start_date) }
    it { should respond_to(:end_date) }
    it { should respond_to(:authenticate!) }
    it { should respond_to(:fetch_data!) }
    it { should respond_to(:authenticated?) }
    it { should respond_to(:username) }
    it { should respond_to(:password) }

# Class methods
  describe "#valid_guid?" do
    it "should recognize legal guids" do
      expect(VolumeHistoryImporter.valid_guid?('414F0BD3-0460-405D-9136-0F16DB212BA9')).to eq true
    end

    it "should recognize an all-zero guid" do
      expect(VolumeHistoryImporter.valid_guid?('00000000-0000-0000-0000-000000000000')).to eq true
    end

    it "should reject all numeric guids" do
      expect(VolumeHistoryImporter.valid_guid?('414F0BD30460405D91360F16DB212BA9')).to eq false
    end

    it "should reject short guids" do
      expect(VolumeHistoryImporter.valid_guid?('414F0BD3-0460-405D-9136-0F16DB212BA')).to eq false
    end

    it "should reject guids embedded in other text" do
      expect(VolumeHistoryImporter.valid_guid?('hell414F0BD3-0460-405D-9136-0F16DB212BA9o')).to eq false
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

  describe "#authenticate" do

    context "when a correct username and password are provided" do
      before { 
        VCR.use_cassette('report_server_auth_good') do
          importer.authenticate!() 
        end
      }
      it "should establish a session when authenticate() is called" do
        expect(importer.authenticated?).to eq true
      end
      it "should record the session id" do
        expect(importer.session_id).not_to be_empty
      end
      it "should have a valid session id" do
        expect(importer.class.valid_guid?(importer.session_id)).to eq true
      end
    end

    context "when an invalid username is provided" do
      before { importer.username = "oir" }
      it "should raise an exception" do
        VCR.use_cassette('report_server_auth_bad_user') do
          expect{ importer.authenticate!() }.to raise_error(SecurityError, "Authentication error- Bad username.")
        end
      end
    end

    context "when an invalid password is provided" do
      before { importer.password = "badpass" }
      it "should raise an exception" do
        VCR.use_cassette('report_server_auth_bad_pass') do
          expect{ importer.authenticate!() }.to raise_error(SecurityError, "Authentication error- Bad password.")
        end
      end
    end
  end

  describe "#fetch_data!" do

    context "when called before authenticate" do
      before { 
        VCR.use_cassette('report_server_fetch_then_auth') do
          importer.fetch_data!() 
        end
      }
      it "should call authenticate and create a session" do
        expect(importer.authenticated?).to eq true
      end
    end

    context "when called after authenticate" do
      it "should not authenticate again before fetching data" do
        VCR.use_cassette('report_server_auth_then_fetch') do
          importer.authenticate!()
          session = importer.session_id
          importer.fetch_data!()
          expect(session).to eq importer.session_id
        end
      end
    end

    context "when called with a single location" do
      it "should retrieve data for only one site" do
        VCR.use_cassette('report_server_single_site') do
          data = importer.fetch_data!()
          JSON.parse(data).each do |record|
            expect(record['ServiceSiteUid']).to eq "414f0bd3-0460-405d-9136-0f16db212ba9"
            expect(record['Name']).to eq "CityMD 57th St"
          end
        end
      end
    end

    context "when called with all locations specified" do
      it "should retrieve data for all locations" do
        VCR.use_cassette('report_server_all_sites') do
          data = all_importer.fetch_data!()
          locations = {}
          JSON.parse(data).each do |record|
            locations[record['Name']] = 1
          end
          expect(locations.keys.length).to be > 10
        end
      end
    end

  end
end
