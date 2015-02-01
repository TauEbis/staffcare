require 'spec_helper'

describe ReportServerFetcher, :type => :service do
  day = Date.parse('2014-07-01')
  let(:fetcher) { ReportServerFetcher.new }
  subject { fetcher }

# Class methods
  describe "#valid_guid?" do
    it "should recognize legal guids" do
      expect(ReportServerFetcher.valid_guid?('414F0BD3-0460-405D-9136-0F16DB212BA9')).to eq true
    end

    it "should recognize an all-zero guid" do
      expect(ReportServerFetcher.valid_guid?('00000000-0000-0000-0000-000000000000')).to eq true
    end

    it "should reject all numeric guids" do
      expect(ReportServerFetcher.valid_guid?('414F0BD30460405D91360F16DB212BA9')).to eq false
    end

    it "should reject short guids" do
      expect(ReportServerFetcher.valid_guid?('414F0BD3-0460-405D-9136-0F16DB212BA')).to eq false
    end

    it "should reject guids embedded in other text" do
      expect(ReportServerFetcher.valid_guid?('hell414F0BD3-0460-405D-9136-0F16DB212BA9o')).to eq false
    end
  end

# Instance Methods
  describe "#authenticated" do

    context "when authenticate() has not been called" do
      it "should return false if authenticate() hasn't run" do
        expect(fetcher.send(:authenticated?)).to eq false
      end
    end
  end

  describe "#authenticate" do

    context "when a correct username and password are provided" do
      before {
        VCR.use_cassette('report_server_auth_good') do
          fetcher.authenticate!()
        end
      }
      it "should establish a session when authenticate() is called" do
        expect(fetcher.send(:authenticated?)).to eq true
      end
      it "should record the session id" do
        expect(fetcher.instance_variable_get(:@session_id)).not_to be_empty
      end
      it "should have a valid session id" do
        expect(fetcher.class.valid_guid?(fetcher.instance_variable_get(:@session_id))).to eq true
      end
    end

    context "when an invalid username is provided" do
      before { fetcher.instance_variable_set(:@username, "oir") }
      it "should raise an exception" do
        VCR.use_cassette('report_server_auth_bad_user') do
          expect{ fetcher.authenticate!() }.to raise_error(SecurityError, "Authentication error- Bad username.")
        end
      end
    end

    context "when an invalid password is provided" do
      before { fetcher.instance_variable_set(:@password, "badpass") }
      it "should raise an exception" do
        VCR.use_cassette('report_server_auth_bad_pass') do
          expect{ fetcher.authenticate!() }.to raise_error(SecurityError, "Authentication error- Bad password.")
        end
      end
    end
  end

  describe "#fetch_data!" do

    context "when called before authenticate" do
      before {
        VCR.use_cassette('report_server_fetch_then_auth') do
          fetcher.fetch_data!(day, day, '414F0BD3-0460-405D-9136-0F16DB212BA9')
        end
      }
      it "should call authenticate and create a session" do
        expect(fetcher.send(:authenticated?)).to eq true
      end
    end

    context "when called after authenticate" do
      it "should not authenticate again before fetching data" do
        VCR.use_cassette('report_server_auth_then_fetch') do
          fetcher.authenticate!()
          session = fetcher.instance_variable_get(:@session_id)
          fetcher.fetch_data!(day, day, '414F0BD3-0460-405D-9136-0F16DB212BA9')
          expect(session).to eq fetcher.instance_variable_get(:@session_id)
        end
      end
    end

    context "when called with a single location" do
      it "should retrieve data for only one site" do
        VCR.use_cassette('report_server_single_site') do
          data = fetcher.fetch_data!(day, day, '414F0BD3-0460-405D-9136-0F16DB212BA9')
          data.each do |record|
            expect(record['ServiceSiteUid']).to eq "414f0bd3-0460-405d-9136-0f16db212ba9"
            expect(record['Name']).to eq "CityMD 57th St"
          end
        end
      end
    end

    context "when called with all locations specified" do
      it "should retrieve data for all locations" do
        VCR.use_cassette('report_server_all_sites') do
          data = fetcher.fetch_data!(day, day, 'ALL')
          locations = {}
          data.each do |record|
            locations[record['Name']] = 1
          end
          expect(locations.keys.length).to be > 10
        end
      end
    end

  end
end
