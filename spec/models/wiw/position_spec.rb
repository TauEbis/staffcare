require 'spec_helper'

RSpec.describe Wiw::Position, :type => :model do

  describe "Listing Positions in WIW" do

    it "returns all the positions" do
      VCR.use_cassette('list_positions') do
        results = Wiw::Position.find_all_collection

        expect(results.size).to eql(7)
        expect(results[0][0]).to eql("Assistant Manager")
        expect(results[0][1]).to eql(867214)
        expect(results[6][0]).to eql("X-Ray Technician")
      end
    end
  end

end
