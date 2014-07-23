require 'spec_helper'

describe Push, :type => :model do
  let(:location_plan) { create(:location_plan) }
  let(:shift) { create(:shift, grade: location_plan.chosen_grade) }
  let(:push)  { location_plan.pushes.build }
  subject { push }

end
