class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :profile, :update, :destroy, :update_profile]

  def index
    @users = policy_scope(User).ordered.page params[:page]
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.invite!(user_params_for_admin)
    authorize @user

    if @user.save
      redirect_to users_path, notice: "User was successfully invited.  They'll receive an email requesting they set their password."
    else
      render :new
    end
  end

  def edit
  end

  def profile
  end

  def update
    if @user.update(user_params_for_admin)
      redirect_to users_path
    else
      render 'edit'
    end
  end

  # POST
  def update_profile
    result = @user.update_with_password(profile_params)

    if result
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to root_path
    else
      render "profile"
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end

  def profile_params
    params.required(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
  end

  def user_params_for_admin
    params.required(:user).permit(:name, :email, :role, {:location_ids => []})
  end
end
