module AuthenticationHelpers
  def log_in_as(user, password: 'Password1!')
    post login_path, params: { email: user.email, password: password }
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
