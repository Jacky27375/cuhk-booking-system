require "rails_helper"

RSpec.describe PasswordResetCode, type: :model do
  subject(:reset_code) { build(:password_reset_code) }

  it "is valid with default factory attributes" do
    expect(reset_code).to be_valid
  end

  it "normalizes email casing and whitespace" do
    reset_code.email = "  MixedCase@link.cuhk.edu.hk  "
    reset_code.validate

    expect(reset_code.email).to eq("mixedcase@link.cuhk.edu.hk")
  end

  it "requires a CUHK email" do
    reset_code.email = "student@example.com"

    expect(reset_code).not_to be_valid
    expect(reset_code.errors[:email]).to include("must be a valid @link.cuhk.edu.hk address")
  end

  describe "#attempts_exhausted?" do
    it "returns true at max attempts" do
      reset_code.attempt_count = PasswordResetCode::MAX_ATTEMPTS
      expect(reset_code.attempts_exhausted?).to be(true)
    end

    it "returns false under max attempts" do
      reset_code.attempt_count = PasswordResetCode::MAX_ATTEMPTS - 1
      expect(reset_code.attempts_exhausted?).to be(false)
    end
  end

  describe "#expired?" do
    it "returns true when expiry time has passed" do
      reset_code.expires_at = 1.minute.ago
      expect(reset_code.expired?).to be(true)
    end

    it "returns false when still within validity window" do
      reset_code.expires_at = 5.minutes.from_now
      expect(reset_code.expired?).to be(false)
    end
  end

  describe "#resend_cooldown_seconds" do
    it "returns a positive value during cooldown" do
      reset_code.last_sent_at = Time.current
      expect(reset_code.resend_cooldown_seconds).to be > 0
    end

    it "returns zero when cooldown has elapsed" do
      reset_code.last_sent_at = 2.minutes.ago
      expect(reset_code.resend_cooldown_seconds).to eq(0)
    end
  end
end
