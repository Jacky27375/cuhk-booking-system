class RegistrationsController < ApplicationController
  skip_before_action :require_authentication, only: [:new, :create]

  def new
    @user = User.new
    @tenants = Tenant.order(:name)
  end

  def create
    @user = User.new(registration_params)
    @user.role = :society_member
    @tenants = Tenant.order(:name)

    if @user.save
      reset_session
      session[:user_id] = @user.id
      redirect_to dashboard_path, notice: "Account created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email, :password, :password_confirmation, :tenant_id)
  end
end
