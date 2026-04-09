class RegistrationsController < ApplicationController
  COLLEGE_TENANT_NAMES = [
    "Chung Chi College",
    "New Asia College",
    "United College",
    "Shaw College",
    "Morningside College",
    "S.H. Ho College",
    "CW Chu College",
    "Wu Yee Sun College",
    "Lee Woo Sing College"
  ].freeze

  skip_before_action :require_authentication, only: [:new, :create]

  def new
    @user = User.new
    @tenants = registration_tenants
  end

  def create
    @user = User.new(registration_params)
    @user.role = :student
    @tenants = registration_tenants

    unless registration_tenant_ids.include?(@user.tenant_id)
      @user.errors.add(:tenant, "must be one of the eligible CUHK colleges")
      render :new, status: :unprocessable_content
      return
    end

    if @user.save
      reset_session
      session[:user_id] = @user.id
      redirect_to dashboard_path, notice: "Account created successfully."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def registration_tenants
    @registration_tenants ||= Tenant.where(name: COLLEGE_TENANT_NAMES).order(:name)
  end

  def registration_tenant_ids
    @registration_tenant_ids ||= registration_tenants.pluck(:id)
  end

  def registration_params
    params.require(:user).permit(:email, :password, :password_confirmation, :tenant_id)
  end
end
