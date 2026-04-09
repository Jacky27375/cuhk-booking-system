class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: [:new, :create]

  def new
  end

  def create
    email = params[:email].to_s.strip.downcase
    user = User.find_by(email: email)

    if user&.authenticate(params[:password])
      if establish_session_lock!(user)
        redirect_to dashboard_path, notice: "Logged in successfully."
      else
        flash.now[:alert] = "This account is already logged in on another device. Please sign out there first."
        render :new, status: :conflict
      end
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    release_session_lock!
    reset_session
    redirect_to login_path, notice: "Logged out successfully."
  end

  private

  def establish_session_lock!(user)
    session_token = nil

    user.with_lock do
      user.reload
      return false if user.active_session_locked?

      session_token = user.issue_active_session_token!
    end

    reset_session
    session[:user_id] = user.id
    session[:active_session_token] = session_token
    true
  end

  def release_session_lock!
    user = User.find_by(id: session[:user_id])
    return unless user

    user.clear_active_session_token!(token: session[:active_session_token])
  end
end
