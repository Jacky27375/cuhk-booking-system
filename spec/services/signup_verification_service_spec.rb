require "rails_helper"

RSpec.describe SignupVerificationService do
  let(:email) { "newstudent@link.cuhk.edu.hk" }

  before do
    ActionMailer::Base.deliveries.clear
  end

  describe ".issue_initial_code" do
    it "creates a verification record and sends an email" do
      result = described_class.issue_initial_code(email:)

      expect(result.status).to eq(:sent)
      record = SignupVerificationCode.find_by!(email:)
      expect(record.expires_at).to be > Time.current
      expect(record.attempt_count).to eq(0)
      expect(record.resend_count).to eq(0)

      mail = ActionMailer::Base.deliveries.last
      delivered_code = mail.body.encoded[/\b\d{6}\b/]
      expect(mail.to).to eq([email])
      expect(delivered_code).to be_present
      expect(BCrypt::Password.new(record.code_digest).is_password?(delivered_code)).to be(true)
    end
  end

  describe ".verify_code" do
    it "accepts a valid code and rejects it after consumption" do
      described_class.issue_initial_code(email:)
      code = ActionMailer::Base.deliveries.last.body.encoded[/\b\d{6}\b/]

      verify_result = described_class.verify_code(email:, submitted_code: code)
      expect(verify_result.success?).to be(true)

      described_class.consume_code!(email:)
      reused_result = described_class.verify_code(email:, submitted_code: code)
      expect(reused_result.status).to eq(:used)
    end

    it "tracks invalid attempts and locks after limit" do
      described_class.issue_initial_code(email:)

      attempts = SignupVerificationCode::MAX_ATTEMPTS
      attempts.times do |_|
        described_class.verify_code(email:, submitted_code: "000000")
      end

      record = SignupVerificationCode.find_by!(email:)
      expect(record.attempt_count).to eq(SignupVerificationCode::MAX_ATTEMPTS)

      result = described_class.verify_code(email:, submitted_code: "000000")
      expect(result.status).to eq(:attempt_limit)
      expect(result.remaining_attempts).to eq(0)
    end

    it "rejects expired codes" do
      create(
        :signup_verification_code,
        email:,
        code_digest: BCrypt::Password.create("123456"),
        expires_at: 1.minute.ago
      )

      result = described_class.verify_code(email:, submitted_code: "123456")
      expect(result.status).to eq(:expired)
    end
  end

  describe ".resend_code" do
    it "enforces cooldown and resend limit" do
      described_class.issue_initial_code(email:)
      cooldown_result = described_class.resend_code(email:)
      expect(cooldown_result.status).to eq(:cooldown)

      record = SignupVerificationCode.find_by!(email:)
      record.update!(last_sent_at: 2.minutes.ago)

      resend_result = described_class.resend_code(email:)
      expect(resend_result.status).to eq(:sent)
      expect(record.reload.resend_count).to eq(1)

      record.update!(last_sent_at: 2.minutes.ago, resend_count: SignupVerificationCode::MAX_RESENDS)
      limit_result = described_class.resend_code(email:)
      expect(limit_result.status).to eq(:resend_limit)
    end
  end
end
