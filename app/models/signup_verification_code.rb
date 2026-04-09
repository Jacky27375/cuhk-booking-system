class SignupVerificationCode < ApplicationRecord
  MAX_ATTEMPTS = 5
  MAX_RESENDS = 3
  CODE_TTL = 10.minutes
  RESEND_COOLDOWN = 60.seconds

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  validates :email, presence: true, format: { with: User::CUHK_EMAIL_REGEX, message: "must be a valid @link.cuhk.edu.hk address" }
  validates :code_digest, presence: true
  validates :expires_at, presence: true
  validates :last_sent_at, presence: true
  validates :attempt_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :resend_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active, -> { where(used_at: nil).where("expires_at > ?", Time.current) }

  def expired?(at_time = Time.current)
    expires_at <= at_time
  end

  def consumed?
    used_at.present?
  end

  def attempts_exhausted?
    attempt_count >= MAX_ATTEMPTS
  end

  def resend_cooldown_seconds(at_time = Time.current)
    return 0 unless last_sent_at.present?

    remaining = (last_sent_at + RESEND_COOLDOWN - at_time).ceil
    remaining.positive? ? remaining : 0
  end
end
