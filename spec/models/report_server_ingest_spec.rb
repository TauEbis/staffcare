require 'spec_helper'

describe ReportServerIngest do
  let(:ingest) { ReportServerIngest.new(start_date: Date.parse('2014-07-01'), end_date: Date.parse('2014-07-01')) }
  let (:record) { IngestRecord.new('loc1') }
  subject { ingest }

# Attributes
  	it { should respond_to(:start_date) }
    it { should respond_to(:end_date) }
    it { should respond_to(:locations) }
    it { should respond_to(:heatmaps) }
    it { should respond_to(:totals) }
    
# Methods
  describe "#add_record" do

    context "when a record is added to the ingest" do
      before { ingest.add_record('loc1', "9264c594-c3d2-483d-84a7-316d538b52c8", 0, "08:00:00", 5.0) }
      it "should add a record correctly" do
        expect(ingest.get_record('loc1').name).to eq 'loc1'
        expect(ingest.get_record('loc1').total_visits.to_i).to eq 5
      end
    end
  end
end
