require 'spec_helper'

describe LocationPlan do
  let (:location_plan) { FactoryGirl.build(:location_plan) }
  subject { location_plan }

# Attributes
  	it { should respond_to(:visits) }
    it { should respond_to(:approval_state) }
    it { should respond_to(:max_mds) }
    it { should respond_to(:rooms) }
    it { should respond_to(:min_openers) }
    it { should respond_to(:min_closers) }
    it { should respond_to(:open_times) }
    it { should respond_to(:close_times) }
    it { should respond_to(:normal) }
    it { should respond_to(:max) }
    it { should respond_to(:wiw_sync) }
    it { should respond_to(:optimizer_state) }
    it { should respond_to(:optimizer_job_id) }
    it { should respond_to(:open_times) }

    describe "normal attribute" do
      it "should save a array with a float" do
        location_plan.normal = [0.0, 5.5, 3.2, 1.1, 7.9, 2494.2933]
        expect(location_plan.save).to eq(true)

        l = LocationPlan.find location_plan.id
        expect(l.normal).to eql([0.0, 5.5, 3.2, 1.1, 7.9, 2494.2933])
      end
    end

# Validations
    it { should be_valid }

    context "when an open_time is too early" do
      before { location_plan.open_times[0] = 7 }
      it {should_not be_valid}
    end

    context "when an open_time is too late" do
      before { location_plan.open_times[0] = 23 }
      it {should_not be_valid}
    end

    context "when an open_time is too early" do
      before { location_plan.close_times[0] = 7 }
      it {should_not be_valid}
    end

    context "when an open_time is too late" do
      before { location_plan.close_times[0] = 23 }
      it {should_not be_valid}
    end

    context "when visits open/close times don't match open/close times" do
      before { location_plan.visits.first[1] << [4] }
      it {should_not be_valid}
    end

    context "when open/close times don't match visits open/close times" do
      before { location_plan.open_times[1] = 10 }
      it {should_not be_valid}
    end

# Delegated Methods
  describe "delegated methods" do
    describe "#days" do
      it "should equal schedule's days" do
        expect(location_plan.days).to eq (location_plan.schedule.days)
      end
    end

    describe "#ftes" do
      it "should equal location's ftes" do
        expect(location_plan.ftes).to eq (location_plan.location.ftes)
      end
    end

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

    describe "#solution_set_options(day)" do
      let(:day)   { location_plan.days.first }

      before do
        location_plan.max_mds = 5
        location_plan.min_openers = 1
        location_plan.min_closers = 1
        location_plan.visits[day.to_s] = Array.new(28, 7)
        location_plan.normal = [4, 8,  12, 16, 24]
        location_plan.max    = [6, 12, 18, 24, 30]
      end

      it "should have the correct options" do
        expected = {open: location_plan.open_times[day.wday], close: location_plan.close_times[day.wday], max_mds: 4, min_openers: 3, min_closers: 3}
        expect(location_plan.solution_set_options(day)).to eq(expected)
      end
    end

    describe "#build_solution_set(day)" do
      let(:day)   { location_plan.days.first }

      before do
        allow(location_plan).to receive(:solution_set_options).and_return({open: 8, close: 22, max_mds: 1, min_openers: 1, min_closers: 1})
      end

      it "should have the correct coverage list" do
        expected = [Array.new(28, 1)]
        expect(location_plan.build_solution_set(day)).to eq(expected)
      end
    end

  end

end
