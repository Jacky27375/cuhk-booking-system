require 'rails_helper'

RSpec.describe SignupVerificationCode, type: :model do
  subject(:verification_code) { build(:signup_verification_code) }

  it "is valid with default factory attributes" do
    expect(verification_code).to be_valid
  end

  it "normalizes email casing and whitespace" do
    verification_code.email = "  MixedCase@link.cuhk.edu.hk  "
    verification_code.validate

    expect(verification_code.email).to eq("mixedcase@link.cuhk.edu.hk")
  end

  it "requires a CUHK email" do
    verification_code.email = "student@example.com"

    expect(verification_code).not_to be_valid
    expect(verification_code.errors[:email]).to include("must be a valid @link.cuhk.edu.hk address")
  end

  describe "#attempts_exhausted?" do
    it "returns true at max attempts" do
      verification_code.attempt_count = SignupVerificationCode::MAX_ATTEMPTS
      expect(verification_code.attempts_exhausted?).to be(true)
    end

    it "returns false under max attempts" do
      verification_code.attempt_count = SignupVerificationCode::MAX_ATTEMPTS - 1
      expect(verification_code.attempts_exhausted?).to be(false)
    end
  end

  describe "#expired?" do
    it "returns true when expiry time has passed" do
      verification_code.expires_at = 1.minute.ago
      expect(verification_code.expired?).to be(true)
    end

    it "returns false when still within validity window" do
      verification_code.expires_at = 5.minutes.from_now
      expect(verification_code.expired?).to be(false)
    end
  end

  describe "#resend_cooldown_seconds" do
    it "returns a positive value during cooldown" do
      verification_code.last_sent_at = Time.current
      expect(verification_code.resend_cooldown_seconds).to be > 0
    end

    it "returns zero when cooldown has elapsed" do
      verification_code.last_sent_at = 2.minutes.ago
      expect(verification_code.resend_cooldown_seconds).to eq(0)
    end
  end
end
