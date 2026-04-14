require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  let!(:allowed_tenant) { create(:tenant, name: 'Chung Chi College') }
  let!(:other_allowed_tenant) { create(:tenant, name: 'New Asia College') }
  let!(:disallowed_tenant) { create(:tenant, name: 'University') }

  before do
    ActionMailer::Base.deliveries.clear
  end

  describe 'GET /signup' do
    it 'shows only allowed college tenants in the registration form' do
      get signup_path

      expect(response).to be_successful
      expect(response.body).to include('Chung Chi College')
      expect(response.body).to include('New Asia College')
      expect(response.body).not_to include('University')
      expect(response.body).to include('@link.cuhk.edu.hk')
      expect(response.body).to include('Generate strong password')
      expect(response.body).to include('At least 10 characters')
      expect(response.body).to include('Includes uppercase, lowercase, number, and symbol')
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

    it 'sends verification code and does not create account before verification' do
      expect {
        post signup_path, params: valid_params
      }.not_to change(User, :count)

      expect(response).to redirect_to(signup_verify_path)
      expect(flash[:notice]).to include('Verification code sent')

      verification = SignupVerificationCode.find_by(email: 'newstudent@link.cuhk.edu.hk')
      expect(verification).to be_present
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it 'rejects weak passwords that do not meet complexity requirements' do
      weak_password_params = valid_params.deep_merge(user: {
        password: 'password12',
        password_confirmation: 'password12'
      })

      expect {
        post signup_path, params: weak_password_params
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(
        'must include at least one uppercase letter, one lowercase letter, one number, and one symbol'
      )
    end

    it 'still ignores role parameter in pending signup data' do
      params_with_staff_role = valid_params.deep_merge(user: { role: 'staff' })

      post signup_path, params: params_with_staff_role

      pending_signup = request.session[:pending_signup]
      expect(pending_signup).to be_present
      expect(pending_signup['email']).to eq('newstudent@link.cuhk.edu.hk')
    end

    it 'rejects registration for a disallowed tenant' do
      disallowed_params = valid_params.deep_merge(user: { tenant_id: disallowed_tenant.id })

      expect {
        post signup_path, params: disallowed_params
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Tenant must be one of the eligible CUHK colleges')
    end

    it 'accepts email local part input and appends CUHK domain' do
      local_part_params = valid_params.deep_merge(user: {
        email: nil,
        email_local_part: '1155209296'
      })

      post signup_path, params: local_part_params

      expect(response).to redirect_to(signup_verify_path)
      expect(flash[:notice]).to include('1155209296@link.cuhk.edu.hk')
      expect(SignupVerificationCode.find_by(email: '1155209296@link.cuhk.edu.hk')).to be_present
    end
  end

  describe 'POST /signup/verify' do
    let(:valid_params) do
      {
        user: {
          email: 'verifiedstudent@link.cuhk.edu.hk',
          password: 'Password1!',
          password_confirmation: 'Password1!',
          tenant_id: allowed_tenant.id
        }
      }
    end

    it 'creates user only after successful verification' do
      post signup_path, params: valid_params
      code = ActionMailer::Base.deliveries.last.body.encoded[/\b\d{6}\b/]

      expect {
        post signup_verify_code_path, params: { verification_code: code }
      }.to change(User, :count).by(1)

      user = User.last
      expect(user.student?).to be(true)
      expect(user.tenant).to eq(allowed_tenant)
      expect(response).to redirect_to(dashboard_path)
      expect(SignupVerificationCode.find_by(email: user.email).used_at).to be_present
    end

    it 'rejects invalid verification code with attempt feedback' do
      post signup_path, params: valid_params

      expect {
        post signup_verify_code_path, params: { verification_code: '000000' }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Invalid verification code. Attempts remaining:')
    end

    it 'rejects expired verification code' do
      post signup_path, params: valid_params
      verification = SignupVerificationCode.find_by!(email: 'verifiedstudent@link.cuhk.edu.hk')
      verification.update!(expires_at: 1.minute.ago)
      code = ActionMailer::Base.deliveries.last.body.encoded[/\b\d{6}\b/]

      expect {
        post signup_verify_code_path, params: { verification_code: code }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Verification code has expired. Please request a new code.')
    end
  end

  describe 'POST /signup/resend_code' do
    let(:valid_params) do
      {
        user: {
          email: 'resendstudent@link.cuhk.edu.hk',
          password: 'Password1!',
          password_confirmation: 'Password1!',
          tenant_id: allowed_tenant.id
        }
      }
    end

    it 'resends code after cooldown' do
      post signup_path, params: valid_params
      verification = SignupVerificationCode.find_by!(email: 'resendstudent@link.cuhk.edu.hk')
      verification.update!(last_sent_at: 2.minutes.ago)

      expect {
        post signup_resend_code_path
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(response).to redirect_to(signup_verify_path)
      expect(flash[:notice]).to eq('A new verification code has been sent.')
      expect(verification.reload.resend_count).to eq(1)
    end

    it 'throttles resend requests made too quickly' do
      post signup_path, params: valid_params

      expect {
        post signup_resend_code_path
      }.not_to change { ActionMailer::Base.deliveries.count }

      expect(response).to redirect_to(signup_verify_path)
      expect(flash[:alert]).to include('Please wait')
    end
  end
end
