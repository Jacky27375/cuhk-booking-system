class RegistrationsController < ApplicationController
  skip_before_action :require_authentication, only: [:new, :create]

  def new
    @user = User.new
    @tenants = signup_tenants
  end

  def create
    @user = User.new(registration_params)
    @user.role = :student
    @tenants = signup_tenants

    if university_tenant_selected?(@user.tenant_id)
      @user.errors.add(:tenant, "must be a college")
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

  def registration_params
    params.require(:user).permit(:email, :password, :password_confirmation, :tenant_id)
  end

  def signup_tenants
    tenants = Tenant.where.not(id: Tenant.university_tenant_ids).order(:name)
    return tenants if tenants.exists?

    DefaultIdentityBootstrap.ensure_college_tenants!
    Tenant.where.not(id: Tenant.university_tenant_ids).order(:name)
  end

  def university_tenant_selected?(tenant_id)
    return false if tenant_id.blank?

    Tenant.university_tenant_ids.where(id: tenant_id).exists?
  end
end
