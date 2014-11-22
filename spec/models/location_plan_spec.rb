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
        location_plan.normal = [5.5, 3.2, 1.1, 7.9, 2494.2933]
        expect(location_plan.save).to eq(true)

        l = LocationPlan.find location_plan.id
        expect(l.normal).to eql([5.5, 3.2, 1.1, 7.9, 2494.2933])
      end
    end

# Validations
  it { should be_valid }

# TODO: Test custom validations and other methods

# Delegated Methods
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
