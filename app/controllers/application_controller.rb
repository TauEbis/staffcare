class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :authenticate_user!, unless: :devise_controller?

  around_filter :set_time_zone

  include Pundit
  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name
  end


  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "Access denied."
    redirect_to (request.referrer || root_path)
  end

  # Zones that are available to the logged-in user
  def user_zones
    policy_scope(Zone.all)
  end

  def user_locations
    policy_scope(current_user.relevant_locations)
  end

  def set_time_zone
    old_time_zone = Time.zone
    Time.zone = current_user.time_zone if user_signed_in?
    yield
  ensure
    Time.zone = old_time_zone
  end
end
