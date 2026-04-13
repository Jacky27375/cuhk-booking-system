require "rails_helper"

RSpec.describe "PasswordResets", type: :request do
  let!(:student_user) { create(:user, :student, email: "studentreset@link.cuhk.edu.hk") }
  let!(:staff_user) { create(:user, :staff, email: "staffreset@link.cuhk.edu.hk") }
  let!(:root_staff_user) { create(:user, :root_account, email: "rootreset@link.cuhk.edu.hk") }
  let!(:admin_user) { create(:user, :admin, email: "adminreset@link.cuhk.edu.hk") }

  before do
    ActionMailer::Base.deliveries.clear
  end

  describe "GET /password_reset" do
    it "renders the reset password form" do
      get password_reset_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Reset Password")
      expect(response.body).to include("@link.cuhk.edu.hk")
    end
  end

  describe "POST /password_reset" do
    it "sends a verification code for students" do
      expect {
        post password_reset_path, params: { email: student_user.email }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(response).to redirect_to(password_reset_verify_path)
      expect(flash[:notice]).to include("Verification code sent")

      record = PasswordResetCode.find_by(email: student_user.email)
      expect(record).to be_present
      expect(request.session[:pending_password_reset]["email"]).to eq(student_user.email)
    end

    it "sends a verification code for non-root staff" do
      post password_reset_path, params: { email: staff_user.email }

      expect(response).to redirect_to(password_reset_verify_path)
      expect(PasswordResetCode.find_by(email: staff_user.email)).to be_present
    end

    it "accepts email local part and canonicalizes to CUHK email" do
      post password_reset_path, params: { email_local_part: "studentreset" }

      expect(response).to redirect_to(password_reset_verify_path)
      expect(PasswordResetCode.find_by(email: "studentreset@link.cuhk.edu.hk")).to be_present
    end

    it "does not reveal whether a non-existent account exists" do
      expect {
        post password_reset_path, params: { email: "missingaccount@link.cuhk.edu.hk" }
      }.not_to change { ActionMailer::Base.deliveries.count }

      expect(response).to redirect_to(password_reset_path)
      expect(flash[:notice]).to eq("If an eligible account exists for this email, a verification code has been sent.")
      expect(PasswordResetCode.find_by(email: "missingaccount@link.cuhk.edu.hk")).to be_nil
    end

    it "rejects root staff accounts" do
      expect {
        post password_reset_path, params: { email: root_staff_user.email }
      }.not_to change { ActionMailer::Base.deliveries.count }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Password reset is only available for student and non-root staff accounts.")
      expect(PasswordResetCode.find_by(email: root_staff_user.email)).to be_nil
    end

    it "rejects admin accounts" do
      expect {
        post password_reset_path, params: { email: admin_user.email }
      }.not_to change { ActionMailer::Base.deliveries.count }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Password reset is only available for student and non-root staff accounts.")
      expect(PasswordResetCode.find_by(email: admin_user.email)).to be_nil
    end
  end

  describe "GET /password_reset/verify" do
    it "requires a pending reset session" do
      get password_reset_verify_path

      expect(response).to redirect_to(password_reset_path)
      expect(flash[:alert]).to eq("Please request a verification code first.")
    end
  end

  describe "POST /password_reset/verify" do
    before do
      student_user.update!(active_session_token: SecureRandom.hex(32))
      post password_reset_path, params: { email: student_user.email }
    end

    it "resets password after valid verification code" do
      code = ActionMailer::Base.deliveries.last.body.encoded[/\b\d{6}\b/]

      post password_reset_verify_code_path, params: {
        verification_code: code,
        password: "NewPassword1!",
        password_confirmation: "NewPassword1!"
      }

      expect(response).to redirect_to(login_path)
      expect(student_user.reload.authenticate("NewPassword1!")).to be_present
      expect(student_user.active_session_token).to be_nil
      expect(PasswordResetCode.find_by(email: student_user.email).used_at).to be_present
    end

    it "rejects invalid verification code" do
      previous_digest = student_user.password_digest

      post password_reset_verify_code_path, params: {
        verification_code: "000000",
        password: "NewPassword1!",
        password_confirmation: "NewPassword1!"
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Invalid verification code. Attempts remaining:")
      expect(student_user.reload.password_digest).to eq(previous_digest)
    end

    it "rejects blank password submission" do
      code = ActionMailer::Base.deliveries.last.body.encoded[/\b\d{6}\b/]

      post password_reset_verify_code_path, params: {
        verification_code: code,
        password: "",
        password_confirmation: ""
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to match(/Password can(?:&#39;|')t be blank\./)
      expect(PasswordResetCode.find_by(email: student_user.email).used_at).to be_nil
    end
  end

  describe "POST /password_reset/resend_code" do
    before do
      post password_reset_path, params: { email: student_user.email }
    end

    it "resends code after cooldown" do
      record = PasswordResetCode.find_by!(email: student_user.email)
      record.update!(last_sent_at: 2.minutes.ago)

      expect {
        post password_reset_resend_code_path
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(response).to redirect_to(password_reset_verify_path)
      expect(flash[:notice]).to eq("A new verification code has been sent.")
      expect(record.reload.resend_count).to eq(1)
    end

    it "throttles resend requests made too quickly" do
      expect {
        post password_reset_resend_code_path
      }.not_to change { ActionMailer::Base.deliveries.count }

      expect(response).to redirect_to(password_reset_verify_path)
      expect(flash[:alert]).to include("Please wait")
    end
  end
end
