require 'spec_helper'

describe VolumeHistoryImporter, :type => :service do
  day = Date.parse('2014-07-01')
  let(:importer) { VolumeHistoryImporter.new(day, day, '414F0BD3-0460-405D-9136-0F16DB212BA9') }
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
      before { importer.authenticate!() }
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
        expect{ importer.authenticate!() }.to raise_error(SecurityError, "Authentication error- Bad username.")
      end
    end

    context "when an invalid password is provided" do
      before { importer.password = "badpass" }
      it "should raise an exception" do
        expect{ importer.authenticate!() }.to raise_error(SecurityError, "Authentication error- Bad password.")
      end
    end
  end

  describe "#fetch_data!" do

    context "when called before authenticate" do
      before { importer.fetch_data!() }
      it "should call authenticate and create a session" do
        expect(importer.authenticated?).to eq true
      end
    end

    context "when called after authenticate" do
      before { importer.authenticate!() }
      it "should not authenticate again before fetching data" do
        session = importer.session_id
        importer.fetch_data!()
        expect(session).to eq importer.session_id
      end
    end

  end


end
