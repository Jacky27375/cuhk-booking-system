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

  PENDING_SIGNUP_SESSION_KEY = :pending_signup

  skip_before_action :require_authentication, only: [:new, :create, :verify, :verify_code, :resend_code]
  before_action :load_registration_tenants, only: [:new, :create]
  before_action :require_pending_signup, only: [:verify, :verify_code, :resend_code]

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.role = :student

    unless registration_tenant_ids.include?(@user.tenant_id)
      @user.errors.add(:tenant, "must be one of the eligible CUHK colleges")
      render :new, status: :unprocessable_content
      return
    end

    if @user.valid?
      session[PENDING_SIGNUP_SESSION_KEY] = pending_signup_payload
      issue_result = SignupVerificationService.issue_initial_code(email: @user.email)

      case issue_result.status
      when :sent
        redirect_to signup_verify_path, notice: "Verification code sent to #{@user.email}."
      when :cooldown
        redirect_to signup_verify_path, alert: "A code was sent recently. Please wait #{issue_result.cooldown_seconds} second(s) before requesting another one."
      when :delivery_unavailable
        flash.now[:alert] = "Verification email is unavailable right now. Please try again later."
        render :new, status: :service_unavailable
      when :delivery_failed
        flash.now[:alert] = "Verification email could not be delivered. Please try again."
        render :new, status: :unprocessable_content
      else
        flash.now[:alert] = "Verification code could not be sent. Please try again."
        render :new, status: :unprocessable_content
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def verify
    @pending_email = pending_signup_data.fetch("email")
  end

  def verify_code
    @pending_email = pending_signup_data.fetch("email")
    verification_result = SignupVerificationService.verify_code(
      email: @pending_email,
      submitted_code: params[:verification_code]
    )

    unless verification_result.success?
      flash.now[:alert] = verification_error_message(verification_result)
      render :verify, status: :unprocessable_content
      return
    end

    @user = user_from_pending_signup
    if @user.save
      SignupVerificationService.consume_code!(email: @pending_email)
      clear_pending_signup
      reset_session
      session[:active_session_token] = @user.issue_active_session_token!
      session[:user_id] = @user.id
      redirect_to dashboard_path, notice: "Account created successfully."
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence.presence || "Account could not be created."
      render :verify, status: :unprocessable_content
    end
  end

  def resend_code
    issue_result = SignupVerificationService.resend_code(email: pending_signup_data.fetch("email"))

    case issue_result.status
    when :sent
      redirect_to signup_verify_path, notice: "A new verification code has been sent."
    when :cooldown
      redirect_to signup_verify_path, alert: "Please wait #{issue_result.cooldown_seconds} second(s) before requesting another code."
    when :resend_limit
      redirect_to signup_verify_path, alert: "Resend limit reached. Use the latest code in your inbox."
    when :delivery_unavailable
      redirect_to signup_verify_path, alert: "Verification email is unavailable right now. Please try again later."
    when :delivery_failed
      redirect_to signup_verify_path, alert: "Verification email could not be delivered. Please try again."
    else
      clear_pending_signup
      redirect_to signup_path, alert: "Verification session expired. Please sign up again."
    end
  end

  private

  def load_registration_tenants
    @tenants = registration_tenants
  end

  def registration_tenants
    @registration_tenants ||= Tenant.where(name: COLLEGE_TENANT_NAMES).order(:name)
  end

  def registration_tenant_ids
    @registration_tenant_ids ||= registration_tenants.pluck(:id)
  end

  def registration_params
    params.require(:user).permit(:email, :password, :password_confirmation, :tenant_id)
  end

  def pending_signup_payload
    {
      "email" => @user.email,
      "password" => registration_params[:password].to_s,
      "password_confirmation" => registration_params[:password_confirmation].to_s,
      "tenant_id" => @user.tenant_id
    }
  end

  def require_pending_signup
    return if pending_signup_data.present?

    redirect_to signup_path, alert: "Please start signup again."
  end

  def pending_signup_data
    data = session[PENDING_SIGNUP_SESSION_KEY]
    data.is_a?(Hash) ? data.with_indifferent_access : nil
  end

  def user_from_pending_signup
    pending_signup = pending_signup_data
    User.new(
      email: pending_signup.fetch("email"),
      password: pending_signup.fetch("password"),
      password_confirmation: pending_signup.fetch("password_confirmation"),
      tenant_id: pending_signup.fetch("tenant_id"),
      role: :student
    )
  end

  def clear_pending_signup
    session.delete(PENDING_SIGNUP_SESSION_KEY)
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
end
