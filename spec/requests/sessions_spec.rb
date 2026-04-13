require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let!(:user) { create(:user, :admin) }

  describe 'GET /login' do
    it 'renders the login form' do
      get login_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Sign In')
      expect(response.body).to include('@link.cuhk.edu.hk')
    end
  end

  describe 'POST /login' do
    it 'logs in with valid credentials and redirects to dashboard' do
      post login_path, params: { email: user.email, password: 'Password1!' }
      expect(response).to redirect_to(dashboard_path)
      expect(user.reload.active_session_token).to be_present
      follow_redirect!
      expect(response.body).to include('Dashboard')
    end

    it 'logs in with local-part identifier' do
      post login_path, params: { email_local_part: user.email.split('@').first, password: 'Password1!' }
      expect(response).to redirect_to(dashboard_path)
    end

    it 'blocks concurrent login attempts for the same account' do
      browser_one = ActionDispatch::Integration::Session.new(Rails.application)
      browser_two = ActionDispatch::Integration::Session.new(Rails.application)

      browser_one.post login_path, params: { email: user.email, password: 'Password1!' }
      expect(browser_one.status).to eq(302)
      expect(browser_one.response.headers['Location']).to end_with(dashboard_path)
      existing_token = user.reload.active_session_token
      expect(existing_token).to be_present

      browser_two.post login_path, params: { email: user.email, password: 'Password1!' }
      expect(browser_two.status).to eq(409)
      expect(browser_two.response.body).to include('already logged in on another device')
      expect(user.reload.active_session_token).to eq(existing_token)

      browser_one.get dashboard_path
      expect(browser_one.status).to eq(200)
    end

    it 'allows login when an existing lock is stale' do
      stale_token = SecureRandom.hex(32)
      user.update!(
        active_session_token: stale_token,
        active_session_token_issued_at: 13.hours.ago
      )

      post login_path, params: { email: user.email, password: 'Password1!' }

      expect(response).to redirect_to(dashboard_path)
      expect(user.reload.active_session_token).not_to eq(stale_token)
      expect(user.active_session_token_issued_at).to be_present
    end

    it 'rejects invalid credentials' do
      post login_path, params: { email: user.email, password: 'wrong' }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Invalid email or password')
    end

    it 'rejects non-existent email' do
      post login_path, params: { email: 'nobody@link.cuhk.edu.hk', password: 'Password1!' }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Invalid email or password')
    end

    it 'accepts a fresh CSRF token after invalidating a stale authenticated session' do
      original_forgery_setting = ActionController::Base.allow_forgery_protection
      ActionController::Base.allow_forgery_protection = true

      browser_one = ActionDispatch::Integration::Session.new(Rails.application)
      browser_two = ActionDispatch::Integration::Session.new(Rails.application)

      browser_one.get(login_path)
      first_authenticity_token = browser_one.response.body[/<form[^>]*action="\/login"[^>]*>.*?name="authenticity_token" value="([^"]+)"/m, 1]
      expect(first_authenticity_token).to be_present

      browser_one.post(login_path, params: {
        authenticity_token: first_authenticity_token,
        email: user.email,
        password: 'Password1!'
      })
      expect(browser_one.status).to eq(302)
      expect(browser_one.response.headers['Location']).to end_with(dashboard_path)

      travel_to(User.active_session_lock_timeout.from_now + 1.second) do
        browser_two.get(login_path)
        second_authenticity_token = browser_two.response.body[/<form[^>]*action="\/login"[^>]*>.*?name="authenticity_token" value="([^"]+)"/m, 1]
        expect(second_authenticity_token).to be_present

        browser_two.post(login_path, params: {
          authenticity_token: second_authenticity_token,
          email: user.email,
          password: 'Password1!'
        })
        expect(browser_two.status).to eq(302)
      end

      browser_one.get(login_path)
      stale_session_token = browser_one.response.body[/<form[^>]*action="\/login"[^>]*>.*?name="authenticity_token" value="([^"]+)"/m, 1]
      expect(stale_session_token).to be_present

      browser_one.post(login_path, params: {
        authenticity_token: stale_session_token,
        email: user.email,
        password: 'Password1!'
      })
      expect(browser_one.status).to eq(409)
      expect(browser_one.response.body).to include('already logged in on another device')
    ensure
      ActionController::Base.allow_forgery_protection = original_forgery_setting
    end
  end

  describe 'DELETE /logout' do
    it 'logs out the user and redirects to login' do
      log_in_as(user)
      expect(user.reload.active_session_token).to be_present

      delete logout_path
      expect(response).to redirect_to(login_path)
      expect(user.reload.active_session_token).to be_nil
    end

    it 'allows login again after logout releases lock' do
      log_in_as(user)
      delete logout_path

      post login_path, params: { email: user.email, password: 'Password1!' }
      expect(response).to redirect_to(dashboard_path)
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

    it 'invalidates stale sessions after session token changes' do
      log_in_as(user)
      user.update!(active_session_token: SecureRandom.hex(32))

      get dashboard_path
      expect(response).to redirect_to(login_path)
    end

    it 'invalidates sessions after lock timeout and releases stale lock' do
      log_in_as(user)

      travel_to(User.active_session_lock_timeout.from_now + 1.second) do
        get dashboard_path
        expect(response).to redirect_to(login_path)
      end

      user.reload
      expect(user.active_session_token).to be_nil
      expect(user.active_session_token_issued_at).to be_nil
    end

    it 'hides Booking link for society member dashboard' do
      member_tenant = create(:tenant, name: 'University', slug: 'university')
      member = create(:user, :student, tenant: member_tenant)

      log_in_as(member)
      get dashboard_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('>Booking<')
      expect(response.body).to include('>My Bookings<')
    end

    it 'hides My Bookings link for staff dashboard' do
      staff_tenant = create(:tenant, name: 'Science Faculty')
      staff = create(:user, :staff, tenant: staff_tenant)

      log_in_as(staff)
      get dashboard_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('>All Bookings<')
      expect(response.body).not_to include('>My Bookings<')
    end

    it 'hides My Bookings link for admin dashboard' do
      admin = create(:user, :admin)

      log_in_as(admin)
      get dashboard_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('>All Bookings<')
      expect(response.body).not_to include('>My Bookings<')
    end
  end
end
