class StaffAccountsController < ApplicationController
  before_action :require_root_account

  def index
    @staff_users = User.where(role: :staff, tenant: current_user.tenant).order(:email)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(staff_account_params)
    @user.role = :staff
    @user.tenant = current_user.tenant

    if @user.save
      redirect_to staff_accounts_path, notice: "Staff account created successfully."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def staff_account_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
