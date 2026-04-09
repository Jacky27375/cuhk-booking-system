require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  let!(:tenant) { create(:tenant) }

  describe 'POST /signup' do
    let(:valid_params) do
      {
        user: {
          email: 'newstudent@link.cuhk.edu.hk',
          password: 'Password1!',
          password_confirmation: 'Password1!',
          tenant_id: tenant.id
        }
      }
    end

    it 'creates a student account' do
      expect {
        post signup_path, params: valid_params
      }.to change(User, :count).by(1)

      user = User.last
      expect(user.student?).to be(true)
      expect(user.tenant).to eq(tenant)
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
  end
end
