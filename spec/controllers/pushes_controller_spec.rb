require 'spec_helper'

RSpec.describe PushesController, :type => :controller do

  let(:location_plan) { create(:location_plan) }

  let(:valid_attributes) { {location_plan_id: location_plan.id} }
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
      push = Push.create! valid_attributes
      get :show, {:id => push.to_param}, valid_session
      expect(assigns(:push)).to eq(push)
    end
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new', location_plan_id: location_plan.to_param
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

      it "assigns a newly created push as @push" do
        post :create, valid_attributes, valid_session
        expect(assigns(:push)).to be_a(Push)
        expect(assigns(:push)).to be_persisted
      end

      it "redirects to the created push" do
        post :create, valid_attributes, valid_session
        expect(response).to redirect_to(Push.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved push as @push" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Push).to receive(:save).and_return(false)
        post :create, valid_attributes, valid_session
        expect(assigns(:push)).to be_a_new(Push)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Push).to receive(:save).and_return(false)
        post :create, valid_attributes, valid_session
        expect(response).to render_template("new")
      end
    end
  end

end
