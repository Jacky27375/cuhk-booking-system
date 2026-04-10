class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_authentication

  helper_method :current_user, :logged_in?, :current_user_department

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = nil
    user_id = session[:user_id]
    return @current_user if user_id.blank?

    user = User.find_by(id: user_id)
    unless user && user.active_session_token_matches?(session[:active_session_token])
      reset_session
      return @current_user
    end

    @current_user = user
  end

  def logged_in?
    current_user.present?
  end

  def require_authentication
    unless logged_in?
      redirect_to login_path, alert: "Please log in to continue."
    end
  end

  def require_admin_or_staff
    unless AuthorizationPolicy.admin_or_staff?(current_user)
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end

  def require_admin
    unless AuthorizationPolicy.admin?(current_user)
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end

  def require_root_account
    unless current_user&.staff? && current_user&.root_account?
      redirect_to dashboard_path, alert: "You are not authorized to perform this action."
    end
  end

  def current_user_department
    current_user&.tenant&.name
  end
end
