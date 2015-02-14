require 'spec_helper'

describe GradesController do

  let(:valid_session) { {} }
  let(:location_plan) { create(:location_plan) }
  let(:parameters)    { { id: location_plan.chosen_grade.id } }

  before { sign_in create(:admin_user) }

  describe 'GET show' do
    before { get :show, parameters, valid_session }

    it 'assigns the requested grade as @grade' do
      expect(assigns(:grade)).to eq location_plan.chosen_grade
    end

    context 'when date is passed' do
      let(:date)       { location_plan.schedule.starts_on }
      let(:parameters) { super().merge({ date: date.to_s, format: :json }) }

      let(:expected)   do
        assigns(:grade)[:visits][date.to_s]
          .map {|count| count.round(2)}
          .to_json
      end

      it 'includes visits per time segment' do
        expect( response.body ).to include expected
      end
    end
  end

  describe "POST create" do

    describe "with valid params" do
      let(:create_params) { {:location_plan_id => location_plan.id, :grade => {:source_grade_id => location_plan.chosen_grade.id}}}

      it "creates a new Grade" do
        location_plan  # Pre-create the original grade

        expect {
          post :create, create_params, valid_session
        }.to change(Grade, :count).by(1)
      end

      it "assigns a newly created grade as @grade" do
        post :create, create_params, valid_session
        expect(assigns(:grade)).to be_a(Grade)
        expect(assigns(:grade)).to be_persisted
      end


      it "copies the default rules to @grade" do
        Position.create_key_positions
        Rule.create_default_template

        post :create, create_params, valid_session
        expect(assigns(:grade).rules.map(&:name)).to eq(Rule.template.map(&:name))
        expect(assigns(:grade).rules.map(&:position)).to eq(Rule.template.map(&:position))
      end

      it "redirects to the line worker rules" do
        post :create, create_params, valid_session
        expect(response).to redirect_to(rules_grade_path(assigns(:grade)))
      end
    end
  end

  #describe "PUT update" do
  #  describe "with valid params" do
  #    it "updates the requested grade" do
  #      grade = Grade.create! valid_attributes
  #      # Assuming there are no other grades in the database, this
  #      # specifies that the Grade created on the previous line
  #      # receives the :update_attributes message with whatever params are
  #      # submitted in the request.
  #      expect_any_instance_of(Grade).to receive(:update).with({ "name" => "MyString" })
  #      put :update, {:id => grade.to_param, :grade => { "name" => "MyString" }}, valid_session
  #    end
  #
  #    it "assigns the requested grade as @grade" do
  #      grade = Grade.create! valid_attributes
  #      put :update, {:id => grade.to_param, :grade => valid_attributes}, valid_session
  #      expect(assigns(:grade)).to eq(grade)
  #    end
  #
  #    it "redirects to the grade" do
  #      grade = Grade.create! valid_attributes
  #      put :update, {:id => grade.to_param, :grade => valid_attributes}, valid_session
  #      expect(response).to redirect_to(grade)
  #    end
  #  end
  #
  #  describe "with invalid params" do
  #    it "assigns the grade as @grade" do
  #      grade = Grade.create! valid_attributes
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      allow_any_instance_of(Grade).to receive(:update).and_return(false)
  #      put :update, {:id => grade.to_param, :grade => { "name" => "invalid value" }}, valid_session
  #      expect(assigns(:grade)).to eq(grade)
  #    end
  #
  #    it "re-renders the 'edit' template" do
  #      grade = Grade.create! valid_attributes
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      allow_any_instance_of(Grade).to receive(:update).and_return(false)
  #      put :update, {:id => grade.to_param, :grade => { "name" => "invalid value" }}, valid_session
  #      expect(response).to render_template("edit")
  #    end
  #  end
  #end

  #describe "DELETE destroy" do
  #  it "destroys the requested grade" do
  #    grade = Grade.create! valid_attributes
  #    expect {
  #      delete :destroy, {:id => grade.to_param}, valid_session
  #    }.to change(Grade, :count).by(-1)
  #  end
  #
  #  it "redirects to the grades list" do
  #    grade = Grade.create! valid_attributes
  #    delete :destroy, {:id => grade.to_param}, valid_session
  #    expect(response).to redirect_to(grades_url)
  #  end
  #end

end
