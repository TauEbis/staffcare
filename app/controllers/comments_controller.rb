class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :set_location_plan

  respond_to :json

  def index
    @comments = @location_plan.comments.ordered.page params[:page]
  end

  def new
    @comment = @location_plan.comments.build(comment_params)
    authorize @comment
  end

  def create
    @comment = Comment.new(
      body: params[:comment][:body].to_s,
      user: current_user,
      location_plan: @location_plan
    )

    authorize @comment

    if @comment.save
      render 'show'
    else
      render json: {errors: @comment.errors.full_messages}
    end
  end

  def show
  end

  #
  # def edit
  # end
  #
  # def update
  #   if @comment.update(comment_params)
  #     redirect_to comments_path
  #   else
  #     render 'edit'
  #   end
  # end
  #
  # def destroy
  #   @comment.destroy
  #   redirect_to comments_url, notice: 'Comment was successfully destroyed.'
  # end

  private

  def set_location_plan
    @location_plan = policy_scope(LocationPlan).find(params[:location_plan_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
    authorize @comment
  end

  def comment_params
    params.required(:comment).permit(:body)
  end
end
