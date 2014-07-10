require 'spec_helper'

describe InputProjection, :type => :model do
	let (:projection) { FactoryGirl.build(:input_projection) }
	subject { projection}

# Attributes
	it { should respond_to(:start_date) }
	it { should respond_to(:end_date) }
	it { should respond_to(:volume_by_location) }

# Validations
	it { should be_valid }

	context "when start_date is not present" do
		before { projection.start_date = nil }
		it {should_not be_valid}
	end

  context "when end_date is not present" do
    before { projection.end_date = nil }
    it { should_not be_valid }
  end

  context "when volume_by_location is not present" do
    before { projection.volume_by_location = nil }
    it { should_not be_valid }
  end

# Scope
  describe "scope" do
		let!(:earlier_projection) { FactoryGirl.create(:input_projection, start_date: Date.today) }
		let!(:later_projection_1) { FactoryGirl.create(:input_projection, start_date: Date.today + 14) }
		let!(:later_projection_2) { FactoryGirl.create(:input_projection, start_date: Date.today + 14) }


    describe "ordered" do
      it "should be in descending order by start date and then id" do
        expect(InputProjection.ordered.to_a).to eq [later_projection_2, later_projection_1, earlier_projection]
      end
    end

    describe "default" do
      it "should be in descending order by start date and then id" do
        expect(InputProjection.ordered.to_a).to eq [later_projection_2, later_projection_1, earlier_projection]
      end
    end
  end

end
