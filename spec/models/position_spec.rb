require 'spec_helper'

describe Position do
  let(:position) { FactoryGirl.build(:position) }
  subject { position }

# Attributes
  	it { should respond_to(:name) }
    it { should respond_to(:wiw_id) }
    it { should respond_to(:hourly_rate) }
    it { should respond_to(:key) }

# Validations
  	it { should be_valid }

  	context "when name is not present" do
  		before { position.name = nil }
  		it {should_not be_valid}
  	end

    context "when name is not unique" do
      let!(:position_2) { FactoryGirl.create(:position, key: :dup, name: 'test') }
      before { position.name = 'test' }
      it {should_not be_valid}
    end

    context "when wiw_id is not a number" do
      before { position.wiw_id = 'a' }
      it {should_not be_valid}
    end

    context "when wiw_id is not unique" do
      let!(:position_2) { FactoryGirl.create(:position, key: :dup, wiw_id: 123) }
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

    context "when key is not unique" do
      let!(:position_2) { FactoryGirl.create(:position, key: 'Manager') }
      before { position.key = 'Manager' }
      it {should_not be_valid}
    end

# Scope
  describe "scope" do
    let!(:a_name) { FactoryGirl.create(:position, name: "Alfred", key: "a") }
    let!(:z_name) { FactoryGirl.create(:position, name: "Zenith", key: "z") }

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

    describe "not_md" do
      let!(:md) { FactoryGirl.create(:position, name: "MD", key: "a") }
      let!(:nil) { FactoryGirl.create(:position, name: "Nil", key: nil) }
      it "should be alphabetically ordered by name" do
        expect(Position.not_md).to eq [a_name, z_name]
      end
    end
  end

# Class Methods
  describe "Position::create_key_positions" do
    before { Position.create_key_positions }

    it "should have the key positions" do
      expect(Position.where(key: :am, name:'Assistant Manager', hourly_rate: 15).count).to eq(1)
      expect(Position.where(key: :ma, name: 'Medical Assistant', hourly_rate: 15 ).count).to eq(1)
      expect(Position.where(key: :manager, name: 'Manager', hourly_rate: 15).count).to eq(1)
      expect(Position.where(key: :md, name: 'Physician', hourly_rate: 180).count).to eq(1)
      expect(Position.where(key: :pcr, name: "Patient Care Representative", hourly_rate: 15).count).to eq(1)
      expect(Position.where(key: :scribe, name: 'Scribe', hourly_rate: 15).count).to eq(1)
      expect(Position.where(key: :xray, name: "X-Ray Technician", hourly_rate: 15).count).to eq(1)
      expect(Position.where(key: :mc).count).to eq(0)
    end
  end

end