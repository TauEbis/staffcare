require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe LocationPlansController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # LocationPlan. As you add validations to LocationPlan, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "name" => "MyString", 'zone_id' => zone.id, 'rooms' => 4, 'max_mds' => 2 } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # LocationPlansController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before do
    sign_in create(:admin_user)
  end

  describe "GET index" do
    it "assigns all location_plans as @location_plans" do
      location_plan = create(:location_plan)
      get :index, {schedule_id: location_plan.schedule_id}, valid_session
      expect(assigns(:location_plans).all).to eq([location_plan])
    end
  end

  describe "GET show" do
    it "assigns the requested location_plan as @location_plan" do
      location_plan = create(:location_plan)
      get :show, {:id => location_plan.to_param}, valid_session
      expect(assigns(:location_plan)).to eq(location_plan)
    end
  end

  describe "POST approve" do
    it "approves a location_plan" do
      location_plan = create(:location_plan)
      expect(location_plan.approval_state).to eq('pending')

      post :approve, {:location_plan_ids => [location_plan.to_param]}, valid_session
      location_plan.reload
      expect(location_plan.approval_state).to eq('approved')
    end

    it "unapproves a location_plan" do
      location_plan = create(:location_plan, approval_state: 'approved')
      expect(location_plan.approval_state).to eq('approved')

      post :approve, {:location_plan_ids => [location_plan.to_param], :reject => true}, valid_session
      location_plan.reload
      expect(location_plan.approval_state).to eq('pending')
    end
  end

  #
  #describe "GET new" do
  #  it "assigns a new location_plan as @location_plan" do
  #    get :new, {}, valid_session
  #    expect(assigns(:location_plan)).to be_a_new(LocationPlan)
  #  end
  #end
  #
  #describe "GET edit" do
  #  it "assigns the requested location_plan as @location_plan" do
  #    location_plan = LocationPlan.create! valid_attributes
  #    get :edit, {:id => location_plan.to_param}, valid_session
  #    expect(assigns(:location_plan)).to eq(location_plan)
  #  end
  #end
  #
  #describe "POST create" do
  #  describe "with valid params" do
  #    it "creates a new LocationPlan" do
  #      expect {
  #        post :create, {:location_plan => valid_attributes}, valid_session
  #      }.to change(LocationPlan, :count).by(1)
  #    end
  #
  #    it "assigns a newly created location_plan as @location_plan" do
  #      post :create, {:location_plan => valid_attributes}, valid_session
  #      expect(assigns(:location_plan)).to be_a(LocationPlan)
  #      expect(assigns(:location_plan)).to be_persisted
  #    end
  #
  #    it "redirects to the created location_plan" do
  #      post :create, {:location_plan => valid_attributes}, valid_session
  #      expect(response).to redirect_to(LocationPlan.last)
  #    end
  #  end
  #
  #  describe "with invalid params" do
  #    it "assigns a newly created but unsaved location_plan as @location_plan" do
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      allow_any_instance_of(LocationPlan).to receive(:save).and_return(false)
  #      post :create, {:location_plan => { "name" => "invalid value" }}, valid_session
  #      expect(assigns(:location_plan)).to be_a_new(LocationPlan)
  #    end
  #
  #    it "re-renders the 'new' template" do
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      allow_any_instance_of(LocationPlan).to receive(:save).and_return(false)
  #      post :create, {:location_plan => { "name" => "invalid value" }}, valid_session
  #      expect(response).to render_template("new")
  #    end
  #  end
  #end
  #
  #describe "PUT update" do
  #  describe "with valid params" do
  #    it "updates the requested location_plan" do
  #      location_plan = LocationPlan.create! valid_attributes
  #      # Assuming there are no other location_plans in the database, this
  #      # specifies that the LocationPlan created on the previous line
  #      # receives the :update_attributes message with whatever params are
  #      # submitted in the request.
  #      expect_any_instance_of(LocationPlan).to receive(:update).with({ "name" => "MyString" })
  #      put :update, {:id => location_plan.to_param, :location_plan => { "name" => "MyString" }}, valid_session
  #    end
  #
  #    it "assigns the requested location_plan as @location_plan" do
  #      location_plan = LocationPlan.create! valid_attributes
  #      put :update, {:id => location_plan.to_param, :location_plan => valid_attributes}, valid_session
  #      expect(assigns(:location_plan)).to eq(location_plan)
  #    end
  #
  #    it "redirects to the location_plan" do
  #      location_plan = LocationPlan.create! valid_attributes
  #      put :update, {:id => location_plan.to_param, :location_plan => valid_attributes}, valid_session
  #      expect(response).to redirect_to(location_plan)
  #    end
  #  end
  #
  #  describe "with invalid params" do
  #    it "assigns the location_plan as @location_plan" do
  #      location_plan = LocationPlan.create! valid_attributes
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      allow_any_instance_of(LocationPlan).to receive(:update).and_return(false)
  #      put :update, {:id => location_plan.to_param, :location_plan => { "name" => "invalid value" }}, valid_session
  #      expect(assigns(:location_plan)).to eq(location_plan)
  #    end
  #
  #    it "re-renders the 'edit' template" do
  #      location_plan = LocationPlan.create! valid_attributes
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      allow_any_instance_of(LocationPlan).to receive(:update).and_return(false)
  #      put :update, {:id => location_plan.to_param, :location_plan => { "name" => "invalid value" }}, valid_session
  #      expect(response).to render_template("edit")
  #    end
  #  end
  #end

end