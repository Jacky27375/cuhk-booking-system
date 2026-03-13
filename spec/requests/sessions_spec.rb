require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let!(:user) { create(:user, :admin) }

  describe 'GET /login' do
    it 'renders the login form' do
      get login_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Log in')
    end
  end

  describe 'POST /login' do
    it 'logs in with valid credentials and redirects to dashboard' do
      post login_path, params: { email: user.email, password: 'Password1!' }
      expect(response).to redirect_to(dashboard_path)
      follow_redirect!
      expect(response.body).to include('Dashboard')
    end

    it 'rejects invalid credentials' do
      post login_path, params: { email: user.email, password: 'wrong' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Invalid email or password')
    end

    it 'rejects non-existent email' do
      post login_path, params: { email: 'nobody@cuhk.edu.hk', password: 'Password1!' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Invalid email or password')
    end
  end

  describe 'DELETE /logout' do
    it 'logs out the user and redirects to login' do
      log_in_as(user)
      delete logout_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'access control' do
    it 'redirects unauthenticated users to login' do
      get dashboard_path
      expect(response).to redirect_to(login_path)
    end

    it 'allows authenticated users to access dashboard' do
      log_in_as(user)
      get dashboard_path
      expect(response).to have_http_status(:ok)
    end
  end
end
