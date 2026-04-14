class Admin::UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: [:destroy, :reset_root_staff_password]

  def index
    @users = User.includes(:tenant).order(:role, :email)
  end

  def destroy
    unless @user.deletable_by_admin?(current_user)
      redirect_to admin_users_path, alert: account_deletion_blocked_message(@user)
      return
    end

    @user.destroy!
    redirect_to admin_users_path, notice: "Account deleted: #{@user.email}"
  rescue ActiveRecord::DeleteRestrictionError, ActiveRecord::RecordNotDestroyed, ActiveRecord::InvalidForeignKey
    redirect_to admin_users_path, alert: "Account could not be deleted because dependent records still reference it."
  end

  def reset_root_staff_password
    unless @user.root_staff_account?
      redirect_to admin_users_path, alert: "Only root staff accounts can be reset here."
      return
    end

    generated_password = User.generate_compliant_password(length: 16)
    @user.password = generated_password
    @user.password_confirmation = generated_password
    @user.save!

    flash[:generated_temp_password] = {
      email: @user.email,
      password: generated_password
    }
    redirect_to admin_users_path,
                notice: "Temporary password generated for #{@user.email}."
  end

  private

  def set_user
    @user = User.find(params.expect(:id))
  end

  def account_deletion_blocked_message(user)
    return "You cannot delete your own admin account." if user == current_user
    return "Root staff accounts are protected and cannot be deleted." if user.root_staff_account?
    return "You cannot delete the last admin account." if user.admin? && User.admin.count <= 1

    "Account could not be deleted."
  end
end
