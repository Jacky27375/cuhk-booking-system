require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  let!(:allowed_tenant) { create(:tenant, name: 'Chung Chi College') }
  let!(:other_allowed_tenant) { create(:tenant, name: 'New Asia College') }
  let!(:disallowed_tenant) { create(:tenant, name: 'University') }

  describe 'GET /signup' do
    it 'shows only allowed college tenants in the registration form' do
      get signup_path

      expect(response).to be_successful
      expect(response.body).to include('Chung Chi College')
      expect(response.body).to include('New Asia College')
      expect(response.body).not_to include('University')
    end
  end

  describe 'POST /signup' do
    let(:valid_params) do
      {
        user: {
          email: 'newstudent@link.cuhk.edu.hk',
          password: 'Password1!',
          password_confirmation: 'Password1!',
          tenant_id: allowed_tenant.id
        }
      }
    end

    it 'creates a student account' do
      expect {
        post signup_path, params: valid_params
      }.to change(User, :count).by(1)

      user = User.last
      expect(user.student?).to be(true)
      expect(user.tenant).to eq(allowed_tenant)
    end

    it 'ignores role parameter and always creates student' do
      params_with_staff_role = valid_params.deep_merge(user: { role: 'staff' })

      expect {
        post signup_path, params: params_with_staff_role
      }.to change(User, :count).by(1)

      user = User.last
      expect(user.student?).to be(true)
    end

    it 'ignores role parameter for admin' do
      params_with_admin_role = valid_params.deep_merge(user: { role: 'admin' })

      expect {
        post signup_path, params: params_with_admin_role
      }.to change(User, :count).by(1)

      user = User.last
      expect(user.student?).to be(true)
    end

    it 'rejects registration for a disallowed tenant' do
      disallowed_params = valid_params.deep_merge(user: { tenant_id: disallowed_tenant.id })

      expect {
        post signup_path, params: disallowed_params
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Tenant must be one of the eligible CUHK colleges')
    end
  end
end
