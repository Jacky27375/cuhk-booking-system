class AdminController < ApplicationController
  before_action :require_admin

  def show
  end

  private

  def require_admin
    unless current_user.admin?
      redirect_to dashboard_path, alert: "You are not authorized to access this page."
    end
  end
end
