require 'spec_helper'

describe VolumeForecaster, :type => :service do

  d = Date.today - Date.today.wday
  start_date = d-20.weeks
  end_date = d-10.weeks-1
  let(:forecaster) { VolumeForecaster.new(start_date..end_date, create(:location)) }

# Sanity check private methods used in calculations
  describe "#dist_to_origin" do
    it "should return the correct distance" do
      date = end_date + 7.weeks
      expect(forecaster.send(:dist_to_origin, date)).to eq(4.5 + 7)
    end

    it "should return the correct distance" do
      date = end_date + 7.weeks + 2.days
      expect(forecaster.send(:dist_to_origin, date)).to eq(4.5 + 8)
    end
  end

  describe "#oly_avg" do
    it "should return the olynpic average" do
      data = [1,1,2,3,3]
      expect(forecaster.send(:oly_avg, data)).to eq(2)
    end

    it "should return the olympic average" do
      data = [1,3,3]
      expect(forecaster.send(:oly_avg, data)).to eq(3)
    end
  end

end
