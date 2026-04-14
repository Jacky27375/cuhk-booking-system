require 'rails_helper'
require 'nokogiri'

RSpec.describe 'Admin user management', type: :request do
  let!(:tenant) { create(:tenant, name: 'New Asia College') }
  let!(:admin) { create(:user, :admin, email: 'admin1@link.cuhk.edu.hk') }
  let!(:other_admin) { create(:user, :admin, email: 'admin2@link.cuhk.edu.hk') }
  let!(:root_staff) { create(:user, :root_account, tenant: tenant, email: 'rootstaff@link.cuhk.edu.hk') }
  let!(:regular_staff) { create(:user, :staff, tenant: tenant, email: 'staff@link.cuhk.edu.hk') }
  let!(:student) { create(:user, :student, tenant: tenant, email: 'student@link.cuhk.edu.hk') }

  describe 'GET /admin/users' do
    it 'allows admin access' do
      log_in_as(admin)

      get admin_users_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('User Management')
      expect(response.body).to include(root_staff.email)
    end

    it 'denies staff access' do
      log_in_as(regular_staff)

      get admin_users_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('You are not authorized to perform this action.')
    end

    it 'shows root staff accounts as protected without delete action' do
      log_in_as(admin)

      get admin_users_path

      document = Nokogiri::HTML(response.body)
      root_row = document.css('tr').find { |row| row.text.include?(root_staff.email) }

      expect(root_row).not_to be_nil
      expect(root_row.text).to include('Protected')
      expect(root_row.at_css("form[action='#{admin_user_path(root_staff)}']")).to be_nil
    end
  end

  describe 'DELETE /admin/users/:id' do
    it 'allows admin to delete non-admin accounts' do
      log_in_as(admin)

      expect {
        delete admin_user_path(student)
      }.to change(User, :count).by(-1)

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:notice]).to include('Account deleted')
    end

    it 'blocks deleting own admin account' do
      log_in_as(admin)

      expect {
        delete admin_user_path(admin)
      }.not_to change(User, :count)

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq('You cannot delete your own admin account.')
    end

    it 'blocks deleting root staff accounts' do
      log_in_as(admin)

      expect {
        delete admin_user_path(root_staff)
      }.not_to change(User, :count)

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq('Root staff accounts are protected and cannot be deleted.')
    end
  end

  describe 'PATCH /admin/users/:id/reset_root_staff_password' do
    it 'resets root staff password and shows temporary password once in flash' do
      log_in_as(admin)

      patch reset_root_staff_password_admin_user_path(root_staff)

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:notice]).to eq("Temporary password generated for #{root_staff.email}.")

      temp_password_payload = flash[:generated_temp_password]
      expect(temp_password_payload).to be_present
      generated_password = temp_password_payload["password"] || temp_password_payload[:password]
      payload_email = temp_password_payload["email"] || temp_password_payload[:email]
      expect(generated_password).to be_present
      expect(payload_email).to eq(root_staff.email)

      root_staff.reload
      expect(root_staff.authenticate(generated_password)).to eq(root_staff)
      expect(root_staff.authenticate('Password1!')).to be_falsey

      follow_redirect!
      expect(response.body).to include('Temporary password generated')
      expect(response.body).to include('Copy')
      expect(response.body).to include(generated_password)
    end

    it 'rejects resetting non-root-staff accounts' do
      log_in_as(admin)

      patch reset_root_staff_password_admin_user_path(regular_staff)

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq('Only root staff accounts can be reset here.')
      expect(regular_staff.reload.authenticate('Password1!')).to eq(regular_staff)
    end
  end
end
