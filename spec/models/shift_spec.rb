require 'spec_helper'

RSpec.describe Shift, :type => :model do
  describe "Scoping the correct day" do
    before do
      s = Time.zone.now.beginning_of_day - 4.hours
      30.times do |i|
        create(:shift, starts_at: s + i.hours)
      end
    end

    it "only finds the shifts that are for a certain day" do
      Shift.for_day(Time.zone.now).count.should == 24
    end
  end
end
