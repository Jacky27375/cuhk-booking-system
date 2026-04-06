module ApiAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_api_key!
  end

  private

  def authenticate_api_key!
    token = extract_token
    if token.blank?
      render json: { error: "Missing API key. Provide via Authorization: Bearer <token> header." }, status: :unauthorized
      return
    end

    api_key = ApiKey.active.find_by(token: token)
    if api_key.nil?
      render json: { error: "Invalid or expired API key." }, status: :unauthorized
      return
    end

    api_key.touch_last_used!
    @current_api_user = api_key.user
    @current_api_key = api_key
  end

  def extract_token
    header = request.headers["Authorization"]
    return header.split(" ").last if header&.start_with?("Bearer ")

    params[:api_key]
  end

  def current_api_user
    @current_api_user
  end

  def current_api_key
    @current_api_key
  end
end
