require 'spec_helper'

RSpec.describe PushesController, :type => :controller do

  let(:location_plan) { create(:location_plan) }

  describe "GET 'new'" do
    it "returns http success" do
      get 'new', location_plan_id: location_plan.to_param
      expect(response).to be_success
    end
  end

end
