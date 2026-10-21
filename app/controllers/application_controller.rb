class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Devise provides current_user, user_signed_in? and authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Sign up requires the username, email and password, where
  # email is unchangeable and username is not.
  # Devise asks for the current password before saving either
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username ], except: [ :email ])
  end

  # After logging in or signing up, go back to either the 
  # login page or your bookshelf
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || user_path(resource)
  end

  private

  def require_admin
    return if current_user&.admin?

    redirect_to root_path, alert: "You don't have access to that page."
  end
end
