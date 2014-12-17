require 'spec_helper'

describe ReportServerIngest do
  let(:ingest) { ReportServerIngest.new(start_date: Date.parse('2014-07-01'), end_date: Date.parse('2014-07-01')) }
  subject { ingest }

# Attributes
  	it { should respond_to(:start_date) }
    it { should respond_to(:end_date) }
    it { should respond_to(:data) }

end
