require 'spec_helper'

describe Position do
  let(:position) { FactoryGirl.build(:position) }
  subject { position }

# Attributes
  	it { should respond_to(:name) }
    it { should respond_to(:wiw_id) }
    it { should respond_to(:hourly_rate) }

# Associations
#    describe "zone association" do
#      its(:zone) {should eq zone}
#    end

# Validations
  	it { should be_valid }

  	context "when name is not present" do
  		before { position.name = nil }
  		it {should_not be_valid}
  	end

    context "when name is not unique" do
      let!(:position_2) { FactoryGirl.create(:position, name: 'test') }
      before { position.name = 'test' }
      it {should_not be_valid}
    end

    context "when wiw_id is not a number" do
      before { position.wiw_id = 'a' }
      it {should_not be_valid}
    end

    context "when wiw_id is not unique" do
      let!(:position_2) { FactoryGirl.create(:position, wiw_id: 123) }
      before { position.wiw_id = 123 }
      it {should_not be_valid}
    end

    context "when hourly_rate is not a number" do
      before { position.hourly_rate = 'a' }
      it {should_not be_valid}
    end

    context "when hourly_rate is not present" do
      before { position.hourly_rate = nil }
      it {should_not be_valid}
    end

# Scope
  describe "scope" do
    let!(:a_name) { FactoryGirl.create(:position, name: "Alfred") }
    let!(:z_name) { FactoryGirl.create(:position, name: "Zenith") }

    describe "ordered" do
      it "should be alphabetically ordered by name" do
        expect(Position.ordered.to_a).to eq [a_name, z_name]
      end
    end

    describe "default" do
      it "should be alphabetically ordered by name" do
        expect(Position.all.to_a).to eq [a_name, z_name]
      end
    end
  end

end