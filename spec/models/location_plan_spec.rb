require 'spec_helper'

describe LocationPlan do
  let (:location_plan) { FactoryGirl.build(:location_plan) }
  subject { location_plan }

# Attributes
    it { should respond_to(:approval_state) }
    it { should respond_to(:wiw_sync) }

# Delegated Methods
  describe "delegated methods" do

    describe "#name" do
      it "should equal location's name" do
        expect(location_plan.name).to eq (location_plan.location.name)
      end
    end
  end

# Class Methods
  describe "class methods" do
    describe "::collective_state" do
      let(:lp_2) { create(:location_plan) }
      let(:lp_3) { create(:location_plan) }
      let(:lps)  { [location_plan, lp_2, lp_3]}
      context "when 1 pending" do
        before do
          location_plan.manager_approved!
          lp_2.rm_approved!
          lp_3.pending!
        end
        it "should be pending" do
          actual = LocationPlan.collective_state(lps)
          expect(actual).to eq("pending")
        end
      end
      context "when 1 manager_approved and none pending" do
        before do
          location_plan.manager_approved!
          lp_2.rm_approved!
          lp_3.rm_approved!
        end
        it "should be pending" do
          actual = LocationPlan.collective_state(lps)
          expect(actual).to eq("manager_approved")
        end
      end
      context "when all rm_approved" do
        before do
          location_plan.rm_approved!
          lp_2.rm_approved!
          lp_3.rm_approved!
        end
        it "should be pending" do
          actual = LocationPlan.collective_state(lps)
          expect(actual).to eq("rm_approved")
        end
      end
    end
  end

# Instance Methods
  describe "instance methods" do

    describe "#dirty!" do
      context "when synced" do
        before { location_plan.synced! }
        it "wiw_sync should be dirty" do
          location_plan.dirty!
          expect(location_plan.dirty?).to be(true)
        end
      end
      context "when not synced" do
        before { location_plan.unsynced! }
        it "wiw_sync should be dirty" do
          location_plan.dirty!
          expect(location_plan.dirty?).to be(false)
        end
      end
    end

    describe "#copy_grade!" do
      let(:lp)    { create(:location_plan, wiw_sync: :synced) }
      let(:user)  { create(:user) }
      let(:g)     { lp.copy_grade!(lp.chosen_grade, user) }

      it "should copy the grade" do
        expect(g.instance_of?(Grade)).to be(true)
        expect(g.source).to eq('manual')
        expect(g.user).to be(user)
        expect(lp.chosen_grade_id).to eq(g.id)
        expect(lp.dirty?).to be(true)
      end
    end

  end

end
