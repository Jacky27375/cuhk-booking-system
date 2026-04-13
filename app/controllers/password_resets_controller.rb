class PasswordResetsController < ApplicationController
  PENDING_PASSWORD_RESET_SESSION_KEY = :pending_password_reset

  skip_before_action :require_authentication, only: [:new, :create, :verify, :update, :resend_code]
  before_action :require_pending_password_reset, only: [:verify, :update, :resend_code]

  def new
  end

  def create
    @pending_email = User.canonicalize_cuhk_email(email_input)
    user = User.find_by(email: @pending_email)

    unless user
      redirect_to password_reset_path, notice: "If an eligible account exists for this email, a verification code has been sent."
      return
    end

    unless eligible_for_password_reset?(user)
      flash.now[:alert] = "Password reset is only available for student and non-root staff accounts."
      render :new, status: :unprocessable_content
      return
    end

    session[PENDING_PASSWORD_RESET_SESSION_KEY] = { "email" => @pending_email }
    issue_result = PasswordResetService.issue_initial_code(email: @pending_email)

    case issue_result.status
    when :sent
      redirect_to password_reset_verify_path, notice: "Verification code sent to #{@pending_email}."
    when :cooldown
      redirect_to password_reset_verify_path, alert: "A code was sent recently. Please wait #{issue_result.cooldown_seconds} second(s) before requesting another one."
    when :delivery_unavailable
      clear_pending_password_reset
      flash.now[:alert] = "Verification email is unavailable right now. Please try again later."
      render :new, status: :service_unavailable
    when :delivery_failed
      clear_pending_password_reset
      flash.now[:alert] = "Verification email could not be delivered. Please try again."
      render :new, status: :unprocessable_content
    else
      clear_pending_password_reset
      flash.now[:alert] = "Verification code could not be sent. Please try again."
      render :new, status: :unprocessable_content
    end
  end

  def verify
    @pending_email = pending_password_reset_data.fetch("email")
  end

  def update
    @pending_email = pending_password_reset_data.fetch("email")
    verification_result = PasswordResetService.verify_code(
      email: @pending_email,
      submitted_code: params[:verification_code]
    )

    unless verification_result.success?
      flash.now[:alert] = verification_error_message(verification_result)
      render :verify, status: :unprocessable_content
      return
    end

    user = User.find_by(email: @pending_email)
    unless eligible_for_password_reset?(user)
      clear_pending_password_reset
      redirect_to password_reset_path, alert: "Password reset session expired. Please start again."
      return
    end

    if password_reset_params[:password].blank?
      flash.now[:alert] = "Password can't be blank."
      render :verify, status: :unprocessable_content
      return
    end

    if user.update(password_reset_params.merge(active_session_token: nil))
      PasswordResetService.consume_code!(email: @pending_email)
      clear_pending_password_reset
      reset_session
      redirect_to login_path, notice: "Password reset successfully. Please sign in with your new password."
    else
      flash.now[:alert] = user.errors.full_messages.to_sentence.presence || "Password could not be reset."
      render :verify, status: :unprocessable_content
    end
  end

  def resend_code
    issue_result = PasswordResetService.resend_code(email: pending_password_reset_data.fetch("email"))

    case issue_result.status
    when :sent
      redirect_to password_reset_verify_path, notice: "A new verification code has been sent."
    when :cooldown
      redirect_to password_reset_verify_path, alert: "Please wait #{issue_result.cooldown_seconds} second(s) before requesting another code."
    when :resend_limit
      redirect_to password_reset_verify_path, alert: "Resend limit reached. Use the latest code in your inbox."
    when :delivery_unavailable
      redirect_to password_reset_verify_path, alert: "Verification email is unavailable right now. Please try again later."
    when :delivery_failed
      redirect_to password_reset_verify_path, alert: "Verification email could not be delivered. Please try again."
    else
      clear_pending_password_reset
      redirect_to password_reset_path, alert: "Password reset session expired. Please start again."
    end
  end

  private

  def email_input
    params[:email_local_part].presence || params[:email]
  end

  def pending_password_reset_data
    data = session[PENDING_PASSWORD_RESET_SESSION_KEY]
    data.is_a?(Hash) ? data.with_indifferent_access : nil
  end

  def require_pending_password_reset
    return if pending_password_reset_data.present?

    redirect_to password_reset_path, alert: "Please request a verification code first."
  end

  def clear_pending_password_reset
    session.delete(PENDING_PASSWORD_RESET_SESSION_KEY)
  end

  def password_reset_params
    params.permit(:password, :password_confirmation)
  end

  def verification_error_message(result)
    case result.status
    when :blank
      "Verification code cannot be blank."
    when :missing
      "Verification code not found. Please request a new code."
    when :used
      "This verification code has already been used."
    when :expired
      "Verification code has expired. Please request a new code."
    when :attempt_limit
      "Too many invalid attempts. Please request a new code."
    else
      "Invalid verification code. Attempts remaining: #{result.remaining_attempts}."
    end
  end

  def eligible_for_password_reset?(user)
    return false unless user

    user.student? || (user.staff? && !user.root_account?)
  end
end
