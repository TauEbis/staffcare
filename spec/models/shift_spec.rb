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

# Validations
  describe "when position is not present" do
    let(:shift) { FactoryGirl.build(:shift, position: nil) }
    subject { shift }

    it {should_not be_valid}
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
    before { Position.create_key_positions }
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


  describe "scopes" do
    let!(:shift_3) { FactoryGirl.create(:shift, starts_at: Time.now + 1.hours, ends_at: Time.now + 3.hours ) }
    let!(:shift_1) { FactoryGirl.create(:shift, starts_at: Time.now, ends_at: Time.now + 8.hours ) }
    let!(:shift_2) { FactoryGirl.create(:shift, starts_at: Time.now, ends_at: Time.now + 9.hours ) }

    describe "ordered" do
      it "should be ordered ascending by starts_at and ends_at" do
        expect(Shift.ordered.to_a).to eq [shift_1, shift_2, shift_3]
      end
    end

    describe "default" do
      it "should be ordered" do
        expect(Shift.all).to eq Shift.ordered
      end
    end

  end

# Methods

  describe "knockout methods" do
    let(:shift) { FactoryGirl.create(:shift) }
    let(:ko_out) { {id: shift.id, starts_hour: shift.starts_hour, ends_hour: shift.ends_hour, date: shift.date, position_key: shift.position.key}}
    let(:ko_in) { {"id" => shift.id, "starts" => shift.starts_hour, "ends" => shift.ends_hour, "date" => shift.date, "position_key" => shift.position.key}}

    describe "#to_knockout" do
      it "should return the correct hash for knockout" do
        expect(shift.to_knockout).to eq(ko_out)
      end
    end

    describe "#from_knockout" do
      let(:date) { shift.date }
      let(:s) { FactoryGirl.build(:shift).from_knockout(date, ko_in)}

      it "should build a shift that matches the knockout" do
        expect(s.starts_hour).to eq(shift.starts_hour)
        expect(s.ends_hour).to eq(shift.ends_hour)
        expect(s.position).to eq(shift.position)
      end
    end

  end
end
