require 'spec_helper'

describe Grade, :type => :model do
  let (:location_plan) { create(:location_plan) }
	let (:grade)         { location_plan.chosen_grade }

  it "comes out of the factory correctly" do
    expect(grade.location_plan.chosen_grade).to eql(grade)
  end


  describe "Deleting a grade" do
    it "ensures that the location_plan has a chosen grade" do
      extra_grade = create(:grade, location_plan: location_plan)

      expect(location_plan.chosen_grade).to eql(grade)
      expect(location_plan.grades.count).to eql(2)

      grade.destroy

      expect(location_plan.reload.chosen_grade).to eql(extra_grade)
    end
  end
end
