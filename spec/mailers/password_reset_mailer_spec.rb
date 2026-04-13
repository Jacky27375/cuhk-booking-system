require "rails_helper"

RSpec.describe PasswordResetMailer, type: :mailer do
  describe "verification_code" do
    let(:recipient) { "resetstudent@link.cuhk.edu.hk" }
    let(:verification_code) { "123456" }
    let(:mail) do
      described_class.with(email: recipient, code: verification_code).verification_code
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Your CUHK password reset code")
      expect(mail.to).to eq([recipient])
      expect(mail.from).to eq([ENV.fetch("RESEND_FROM_EMAIL", "noreply@csci3100.tylerl.cyou")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include(verification_code)
      expect(mail.body.encoded).to include("This code will expire in 10 minutes.")
    end
  end
end
