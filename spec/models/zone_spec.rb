require 'spec_helper'

describe Zone, :type => :model do
  let(:zone) { FactoryGirl.create(:zone) }
  let (:location) { FactoryGirl.create(:location, zone: zone) }
  subject { zone }

# Attributes
    it { should respond_to(:to_s) }
    it { should respond_to(:name) }
    #it.to_s { should eq "MyString" }

# Associations
=begin
    describe "association" do
     location.zone { should eq zone }
    end
=end

# Validations
  	it { should be_valid }

  	context "when zone name is not present" do
  		before { zone.name = nil }
  		it {should_not be_valid}
  	end

    context "when zone name is the empty string" do
         before { zone.name = "" }
         it { should_not be_valid }
    end

# Scope
  describe "scope" do
    let!(:a_name) { FactoryGirl.create(:zone, name: "Alfred_St") }
    let!(:z_name) { FactoryGirl.create(:zone, name: "Zenith_St") }

    describe "ordered" do
      it "should be alphabetically ordered by name" do
        expect(Zone.ordered.to_a).to eq [a_name, z_name]
      end
    end

    describe "default" do
      it "should be alphabetically ordered by name" do
        expect(Zone.all.to_a).to eq [a_name, z_name]
      end
    end
  end

# Methods
=begin
  describe "to_s" do
     zone.to_s { should eq "MyString" }
    end
=end
end

