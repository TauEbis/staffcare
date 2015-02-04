require 'spec_helper'

describe ReportServerIngestor do
  let(:data)     { JSON.parse( "[{\"Name\":\"CityMD 14th St\",\"ServiceSiteUid\":\"3ecc8854-f77b-4834-b42f-6b0e4d498b43\",\"VisitDay\":1,\"VisitHour\":\"08:00:00\",\"VisitCount\":0.000000}]" ) }
  let(:ingestor) { ReportServerIngestor.new }
  subject { ingestor }

  before do
    ingestor.instance_variable_set(:@start_date, Date.parse('2014-07-01'))
    ingestor.instance_variable_set(:@end_date, Date.parse('2014-07-01'))
    ingestor.instance_variable_set(:@data, data)
  end

# Methods
  describe "#hash_by_location" do
    before { ingestor.hash_data_by_location }
    it "should hash the visits data by location" do
      locations_hash = ingestor.instance_variable_get(:@locations_hash)
      expect(locations_hash['CityMD 14th St'][:uid]).to eq '3ecc8854-f77b-4834-b42f-6b0e4d498b43'
      expect(locations_hash['CityMD 14th St'][:day_volumes]).to eq( {'Sunday' => {'08:00:00' => 0.000000} } )
    end
  end

  pending "#create_ingest!"
  pending "#create_locations!"
  pending "#create_heatmaps!"
end
