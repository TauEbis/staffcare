require 'spec_helper'

RSpec.describe PushesController, :type => :controller do

  let(:location_plan) { create(:location_plan) }

  let(:valid_attributes) { {location_plan_ids: [location_plan.to_param]} }
  let(:valid_session) { {} }

  before do
    sign_in create(:admin_user)
  end

  before do
    wiw_pusher = double("wiw_pusher", creates: [], updates: [], deletes: [])
    allow(wiw_pusher).to receive(:push) { location_plan.pushes.build }
    allow(WiwPusher).to receive(:new) { wiw_pusher }
  end

  describe "GET show" do
    it "assigns the requested push as @push" do
      push = location_plan.pushes.create!
      get :show, {:id => push.to_param}, valid_session
      expect(assigns(:push)).to eq(push)
    end
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new', schedule_id: location_plan.schedule.to_param
      expect(response).to be_success
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Push" do
        expect {
          post :create, valid_attributes, valid_session
        }.to change(Push, :count).by(1)
      end

      it "redirects to the created push" do
        post :create, valid_attributes, valid_session
        expect(response).to redirect_to(pushes_url(schedule_id: location_plan.schedule_id))
      end
    end
  end

end
