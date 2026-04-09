require 'rails_helper'

RSpec.describe 'Admin access control', type: :request do
  let!(:admin)  { create(:user, :admin) }
  let!(:staff)  { create(:user, :staff) }
  let!(:member) { create(:user, :student) }

  describe 'GET /admin' do
    it 'allows admin access' do
      log_in_as(admin)
      get admin_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Admin Panel')
      expect(response.body).to include('Manage Users')
      expect(response.body).to include('Review Pending Requests')
      expect(response.body).to include('/venue_requests?status=pending')
    end

    it 'denies staff access and redirects to dashboard' do
      log_in_as(staff)
      get admin_path
      expect(response).to redirect_to(dashboard_path)
      follow_redirect!
      expect(response.body).to include('You are not authorized')
    end

    it 'denies society member access and redirects to dashboard' do
      log_in_as(member)
      get admin_path
      expect(response).to redirect_to(dashboard_path)
      follow_redirect!
      expect(response.body).to include('You are not authorized')
    end

    it 'redirects unauthenticated users to login' do
      get admin_path
      expect(response).to redirect_to(login_path)
    end
  end
end
