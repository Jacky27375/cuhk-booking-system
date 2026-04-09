require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  let!(:college_tenant) { create(:tenant, name: 'Shaw College', slug: 'shaw-college') }
  let!(:university_tenant) { create(:tenant, name: 'University', slug: 'university') }

  describe 'GET /signup' do
    it 'does not list the University tenant in signup options' do
      get signup_path

      expect(response).to have_http_status(:ok)

      tenant_options = Nokogiri::HTML.parse(response.body)
                              .css('select#user_tenant_id option')
                              .map { |option| option.text.strip }

      expect(tenant_options).to include(college_tenant.name)
      expect(tenant_options).not_to include(university_tenant.name)
    end

    context 'when tenant records are missing' do
      it 'bootstraps college options for registration' do
        original_university_ids = Tenant.method(:university_tenant_ids)
        first_call = true

        allow(Tenant).to receive(:university_tenant_ids) do
          if first_call
            first_call = false
            Tenant.select(:id)
          else
            original_university_ids.call
          end
        end
        expect(DefaultIdentityBootstrap).to receive(:ensure_college_tenants!).and_call_original

        get signup_path

        expect(response).to have_http_status(:ok)

        tenant_options = Nokogiri::HTML.parse(response.body)
                                .css('select#user_tenant_id option')
                                .map { |option| option.text.strip }

        expect(tenant_options).to include('Shaw College')
        expect(tenant_options).to include('Chung Chi College')
        expect(tenant_options).not_to include('University')
      end
    end
  end

  describe 'POST /signup' do
    let(:valid_params) do
      {
        user: {
          email: 'newstudent@link.cuhk.edu.hk',
          password: 'Password1!',
          password_confirmation: 'Password1!',
          tenant_id: college_tenant.id
        }
      }
    end

    it 'creates a student account' do
      expect {
        post signup_path, params: valid_params
      }.to change(User, :count).by(1)

      user = User.last
      expect(user.student?).to be(true)
      expect(user.tenant).to eq(college_tenant)
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

    it 'rejects signup attempts with the University tenant' do
      params_with_university_tenant = valid_params.deep_merge(user: { tenant_id: university_tenant.id })

      expect {
        post signup_path, params: params_with_university_tenant
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Tenant must be a college')
    end
  end
end
