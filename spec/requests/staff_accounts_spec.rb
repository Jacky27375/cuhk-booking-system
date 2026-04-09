require 'rails_helper'

RSpec.describe 'Staff Accounts', type: :request do
  let!(:tenant) { create(:tenant) }
  let!(:other_tenant) { create(:tenant) }
  let!(:root_user) { create(:user, :root_account, tenant: tenant) }
  let!(:regular_staff) { create(:user, :staff, tenant: tenant) }
  let!(:student) { create(:user, :student, tenant: tenant) }
  let!(:admin) { create(:user, :admin) }

  describe 'GET /staff_accounts' do
    it 'allows root account access' do
      log_in_as(root_user)
      get staff_accounts_path
      expect(response).to have_http_status(:ok)
    end

    it 'denies non-root staff access' do
      log_in_as(regular_staff)
      get staff_accounts_path
      expect(response).to redirect_to(dashboard_path)
    end

    it 'denies student access' do
      log_in_as(student)
      get staff_accounts_path
      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe 'POST /staff_accounts' do
    let(:valid_params) do
      { user: { email: 'newstaff@link.cuhk.edu.hk', password: 'Password1!', password_confirmation: 'Password1!' } }
    end

    it 'allows root account to create staff in same college' do
      log_in_as(root_user)

      expect {
        post staff_accounts_path, params: valid_params
      }.to change(User, :count).by(1)

      new_user = User.find_by(email: 'newstaff@link.cuhk.edu.hk')
      expect(new_user.staff?).to be(true)
      expect(new_user.tenant).to eq(tenant)
      expect(new_user.college_scope_slug).to eq(tenant.slug)
      expect(response).to redirect_to(staff_accounts_path)
    end

    it 'denies non-root staff from creating accounts' do
      log_in_as(regular_staff)

      expect {
        post staff_accounts_path, params: valid_params
      }.not_to change(User, :count)

      expect(response).to redirect_to(dashboard_path)
    end
  end
end
