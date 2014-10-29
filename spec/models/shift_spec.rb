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

# Associations
  describe "position association" do
    let(:position) { FactoryGirl.create(:position) }
    let(:shift) { FactoryGirl.create(:shift, position: position) }

    it "should associate to the correct shift" do
      expect(shift.position).to eq(position)
    end
  end

# Scopes
  describe "position scopes" do
    before(:all) { Position.create_key_positions }
    let!(:s_am)       { create(:shift, position: Position.find_by(key: :am)) }
    let!(:s_ma)       { create(:shift, position: Position.find_by(key: :ma)) }
    let!(:s_manager)  { create(:shift, position: Position.find_by(key: :manager)) }
    let!(:s_md)       { create(:shift, position: Position.find_by(key: :md)) }
    let!(:s_pcr)      { create(:shift, position: Position.find_by(key: :pcr)) }
    let!(:s_scribe)   { create(:shift, position: Position.find_by(key: :scribe)) }
    let!(:s_xray)     { create(:shift, position: Position.find_by(key: :xray)) }

    it "should return shifts with the correct keys" do
      expect(Shift.am).to eq [s_am]
      expect(Shift.ma).to eq [s_ma]
      expect(Shift.manager).to eq [s_manager]
      expect(Shift.md).to eq [s_md]
      expect(Shift.pcr).to eq [s_pcr]
      expect(Shift.scribe).to eq [s_scribe]
      expect(Shift.xray).to eq [s_xray]
      expect(Shift.line_workers).to eq([s_am, s_ma, s_manager, s_pcr, s_scribe, s_xray])
      expect(Shift.line_workers).not_to include(s_md)
      expect(Shift.not_md).to include(s_am, s_ma, s_manager, s_pcr, s_scribe, s_xray)
      expect(Shift.not_md).not_to include(s_md)
    end

  end
end
