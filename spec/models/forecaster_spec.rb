require 'spec_helper'

describe Forecaster, :type => :model do

  describe "self.#ol_avg" do
    it "should return the olynpic average" do
      data = [1,1,2,3,3]
      expect(Forecaster.ol_avg(data)).to eq(2)
    end

    it "should return the olynpic average" do
      data = [1,3,3]
      expect(Forecaster.ol_avg(data)).to eq(3)
    end
  end

end
