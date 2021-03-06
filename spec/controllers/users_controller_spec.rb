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

describe UsersController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "name" => "Test User", "email" => "test@test.com"} }
  let(:update_attributes) { valid_attributes.merge(:current_password => 'password') }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before do
    @admin_user = create(:admin_user)
    sign_in @admin_user
  end

  describe "GET index" do
    it "assigns all users as @users" do
      user = FactoryGirl.create(:user)
      get :index, {}, valid_session
      expect(assigns(:users)).to eq(User.ordered.page)
    end
  end

  describe "GET new" do
    it "assigns a new user as @user" do
      get :new, {}, valid_session
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "GET edit" do
    it "assigns the requested user as @user" do
      user = FactoryGirl.create(:user)
      get :edit, {:id => user.to_param}, valid_session
      expect(assigns(:user)).to eq(user)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new User" do
        expect {
          post :create, {:user => valid_attributes}, valid_session
        }.to change(User, :count).by(1)
      end

      it "assigns a newly created user as @user" do
        post :create, {:user => valid_attributes}, valid_session
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user)).to be_persisted
      end

      it "redirects to the created user" do
        post :create, {:user => valid_attributes}, valid_session
        expect(response).to redirect_to(users_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(User).to receive(:save).and_return(false)
        post :create, {:user => { "name" => "invalid value" }}, valid_session
        expect(assigns(:user)).to be_a_new(User)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(User).to receive(:save).and_return(false)
        post :create, {:user => { "name" => "invalid value" }}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested user" do
        user = FactoryGirl.create(:user)
        # Assuming there are no other users in the database, this
        # specifies that the User created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(User).to receive(:update).with({ "name" => "MyString" })
        put :update, {:id => user.to_param, :user => { "name" => "MyString" }}, valid_session
      end

      it "assigns the requested user as @user" do
        user = FactoryGirl.create(:user)
        put :update, {:id => user.to_param, :user => valid_attributes}, valid_session
        expect(assigns(:user)).to eq(user)
      end

      it "redirects to the users path" do
        user = FactoryGirl.create(:user)
        put :update, {:id => user.to_param, :user => valid_attributes}, valid_session
        expect(response).to redirect_to(users_path)
      end
    end

    describe "with invalid params" do
      it "assigns the user as @user" do
        user = FactoryGirl.create(:user)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(User).to receive(:update).and_return(false)
        put :update, {:id => user.to_param, :user => { "name" => "invalid value" }}, valid_session
        expect(assigns(:user)).to eq(user)
      end

      it "re-renders the 'edit' template" do
        user = FactoryGirl.create(:user)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(User).to receive(:update).and_return(false)
        put :update, {:id => user.to_param, :user => { "name" => "invalid value" }}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "GET profile" do
    it "assigns the requested user as @user" do
      user = @admin_user
      get :profile, {:id => user.to_param}, valid_session
      expect(assigns(:user)).to eq(user)
    end
  end

  describe "POST update_profile" do
    describe "with valid params" do
      it "updates the requested user" do
        user = @admin_user
        expect_any_instance_of(User).to receive(:update_with_password).with({ "name" => "MyString" })
        post :update_profile, {:id => user.to_param, :user => { "name" => "MyString" }}, valid_session
      end

      it "assigns the requested user as @user" do
        user = @admin_user
        post :update_profile, {:id => user.to_param, :user => update_attributes}, valid_session
        expect(assigns(:user)).to eq(user)
      end

      it "redirects to the root path" do
        user = @admin_user
        post :update_profile, {:id => user.to_param, :user => update_attributes}, valid_session
        expect(response).not_to render_template('profile')
        expect(response).to redirect_to(root_path)
      end
    end

    describe "with invalid params" do
      it "assigns the user as @user" do
        user = @admin_user
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(User).to receive(:update_with_password).and_return(false)
        put :update_profile, {:id => user.to_param, :user => { "name" => "invalid value" }}, valid_session
        expect(assigns(:user)).to eq(user)
      end

      it "re-renders the 'profile' template" do
        user = @admin_user
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(User).to receive(:update_with_password).and_return(false)
        put :update_profile, {:id => user.to_param, :user => { "name" => "invalid value" }}, valid_session
        expect(response).to render_template("profile")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested user" do
      user = FactoryGirl.create(:user)
      expect {
        delete :destroy, {:id => user.to_param}, valid_session
      }.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      user = FactoryGirl.create(:user)
      delete :destroy, {:id => user.to_param}, valid_session
      expect(response).to redirect_to(users_url)
    end
  end

end
