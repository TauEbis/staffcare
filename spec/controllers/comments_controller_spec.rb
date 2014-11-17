require 'spec_helper'

RSpec.describe CommentsController, :type => :controller do
  let(:valid_session) { {} }

  let(:comment) { create(:comment) }
  let(:location_plan) { comment.location_plan }

  before do
    sign_in create(:admin_user)
  end

  describe "GET index" do
    it "assigns all comments as @comments" do
      comment
      expect(Comment.count).to eq(1)

      get :index, {location_plan_id: location_plan.id, format: :json}, valid_session
      expect(assigns(:comments).all).to eq([comment])

      r = JSON.parse(response.body)
      expect(r).to be_a(Array)
    end
  end

  describe "GET show" do
    it "returns the comment" do
      comment
      expect(Comment.count).to eq(1)

      get :show, {location_plan_id: location_plan.id, id: comment.id, format: :json}, valid_session
      expect(assigns(:comment)).to eq(comment)

      r = JSON.parse(response.body)
      expect(r['id']).to eq(comment.id)
    end
  end

  describe "POST create" do
    it "returns the comment" do
      expect(Comment.count).to eq(0)

      lp = create(:location_plan)
      post :create, {location_plan_id: lp.id, comment: {body: "Hello World"}, format: :json}, valid_session

      expect(Comment.count).to eq(1)
      c = Comment.last
      expect(c.body).to eq("Hello World")

      r = JSON.parse(response.body)
      expect(r['id']).to eq(c.id)
    end
  end
end
