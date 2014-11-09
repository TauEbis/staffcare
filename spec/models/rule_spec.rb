require 'spec_helper'

describe Rule, :type => :model do
  let(:position) { FactoryGirl.build(:position) }
  let(:grade) { FactoryGirl.build(:grade) }
  let(:rule) { FactoryGirl.build(:rule, grade: grade, position: position) }
  subject { rule }

# Attributes
    it { should respond_to(:name) }
    it { should respond_to(:position_id) }
    it { should respond_to(:grade_id) }
    it { should respond_to(:shift_space_params) }
    it { should respond_to(:step_params) }

# Associations

    describe "grade association" do
      specify { expect(rule.grade).to eq grade }
    end

    describe "position association" do
      specify { expect(rule.position).to eq position }
    end

# Validations
  	it { should be_valid }

  	context "when name is not present" do
  		before { rule.name = nil }
  		it {should_not be_valid}
  	end

    context "when position is not present" do
      before { rule.position = nil }
      it { should_not be_valid }
    end

    context "when position is not unique for each grade" do
      let!(:rule2) { FactoryGirl.create(:rule, grade: grade, position: position) }
      it { should_not be_valid }
      after { rule2.destroy }
    end

    it { should be_valid }


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

# Scopes
  describe "scopes" do
    let!(:r_am)       { create(:rule, position: create(:position, key: :am)) }
    let!(:r_ma)       { create(:rule, position: create(:position, key: :ma)) }
    let!(:r_manager)  { create(:rule, position: create(:position, key: :manager)) }
    let!(:r_pcr)      { create(:rule, position: create(:position, key: :pcr)) }
    let!(:r_scribe)   { create(:rule, position: create(:position, key: :scribe), grade: nil) }
    let!(:r_xray)     { create(:rule, position: create(:position, key: :xray), grade: nil) }

    it "positions scopes should return rules with the correct keys" do
      expect(Rule.am).to eq [r_am]
      expect(Rule.ma).to eq [r_ma]
      expect(Rule.manager).to eq [r_manager]
      expect(Rule.pcr).to eq [r_pcr]
      expect(Rule.scribe).to eq [r_scribe]
      expect(Rule.xray).to eq [r_xray]
    end

    it "default scope should be the ordered scope" do
      expect(Rule.all).to eq(Rule.ordered)
    end

    it "ordered scope should be by position_id" do
      expect(Rule.ordered).to eq([r_am, r_ma, r_manager, r_pcr, r_scribe, r_xray])
      expect(Rule.template).to eq([r_scribe, r_xray])
    end

    it "template scope should be all nil grade_ids" do
      expect(Rule.ordered).to eq([r_am, r_ma, r_manager, r_pcr, r_scribe, r_xray])
      expect(Rule.template).to eq([r_scribe, r_xray])
    end
  end

# Class Methods
  describe "Rule::create_default_template" do
    before do
      Position.create_key_positions
      Rule.create_default_template
    end

    it "should have the default rules template" do
      goal = { am: :salary, ma: :limit_1, manager: :salary, pcr: :ratio_1, scribe: :ratio_2, xray: :limit_1 }
      template = Hash[ Rule.template.map{|r| [r.position.key.to_sym, r.name.to_sym ]} ]
      expect(template).to eq(goal)
    end
  end

  describe "Rule::set_default_params" do
    before do
      rule.shift_space_params = {}
      rule.step_params = {}
      Rule.set_default_params(rule)
    end

    let(:space)  { { "staff_min" => 1, "staff_max" => 2, "shift_min" => 6, "shift_max" => 12 } }
    let(:step)   { { "steps" => [0, 0, 8, 12, -1] } }

    it "should have the default params" do
      expect( rule.shift_space_params ).to eq(space)
      expect( rule.step_params ).to eq(step)
    end
  end

  describe "Rule::copy_template_to_grade" do
    let!(:new_grade) { FactoryGirl.create(:grade) }

    before do
      Position.create_key_positions
      Rule.create_default_template
      Rule.copy_template_to_grade(new_grade)
    end

    it "should have the template rules" do
      template = Hash[ Rule.template.map{   |r| [r.position.name, r.name]} ]
      copy     = Hash[ new_grade.rules.map{ |r| [r.position.name, r.name]} ]
      expect(copy).to eq(template)
    end
  end

# Instance Methods
  describe "#label" do

    LABELS = [ 'Single Coverage',
            'Average of One-and-a-half Coverage',
            'Double Coverage',
            '1 to 1 Physician Ratio',
            '1.5 to 1 Physician Ratio',
            '2 to 1 Physician Ratio',
            'Step-up by Physician',
            'Step-up by Patient',
            'Salary' ]

    before(:all) do
      Position.create_key_positions
      Rule.create_default_template
    end

    Rule::names.keys.each do |name|
      it "should have the correct label" do
        rule.name = name
        expect(rule.label).to eq(LABELS[Rule::names[name]])
      end
    end
  end

end
