class SignupVerificationService
  CODE_FORMAT = "%06d"

  IssueResult = Struct.new(:status, :cooldown_seconds, keyword_init: true) do
    def sent?
      status == :sent
    end
  end

  VerifyResult = Struct.new(:status, :remaining_attempts, keyword_init: true) do
    def success?
      status == :ok
    end
  end

  class << self
    def issue_initial_code(email:)
      issue_code(email:, resend: false)
    end

    def resend_code(email:)
      issue_code(email:, resend: true)
    end

    def verify_code(email:, submitted_code:)
      normalized_email = normalize_email(email)
      code = submitted_code.to_s.strip
      return VerifyResult.new(status: :blank, remaining_attempts: SignupVerificationCode::MAX_ATTEMPTS) if code.blank?

      record = SignupVerificationCode.find_by(email: normalized_email)
      return VerifyResult.new(status: :missing, remaining_attempts: 0) unless record
      return VerifyResult.new(status: :used, remaining_attempts: 0) if record.consumed?
      return VerifyResult.new(status: :expired, remaining_attempts: 0) if record.expired?
      return VerifyResult.new(status: :attempt_limit, remaining_attempts: 0) if record.attempts_exhausted?

      if BCrypt::Password.new(record.code_digest).is_password?(code)
        VerifyResult.new(
          status: :ok,
          remaining_attempts: [SignupVerificationCode::MAX_ATTEMPTS - record.attempt_count, 0].max
        )
      else
        record.increment!(:attempt_count)
        remaining_attempts = [SignupVerificationCode::MAX_ATTEMPTS - record.attempt_count, 0].max
        status = remaining_attempts.zero? ? :attempt_limit : :invalid
        VerifyResult.new(status:, remaining_attempts:)
      end
    end

    def consume_code!(email:)
      record = SignupVerificationCode.find_by!(email: normalize_email(email))
      record.update!(used_at: Time.current)
    end

    private

    def issue_code(email:, resend:)
      normalized_email = normalize_email(email)
      record = SignupVerificationCode.find_or_initialize_by(email: normalized_email)
      now = Time.current

      if resend && !record.persisted?
        return IssueResult.new(status: :missing)
      end

      cooldown_seconds = record.resend_cooldown_seconds(now)
      if cooldown_seconds.positive?
        return IssueResult.new(status: :cooldown, cooldown_seconds:)
      end

      if resend && record.resend_count >= SignupVerificationCode::MAX_RESENDS
        return IssueResult.new(status: :resend_limit)
      end

      code = generate_code
      record.code_digest = BCrypt::Password.create(code)
      record.expires_at = now + SignupVerificationCode::CODE_TTL
      record.used_at = nil
      record.attempt_count = 0
      record.last_sent_at = now
      record.resend_count = resend && record.persisted? ? record.resend_count + 1 : 0
      record.save!

      SignupVerificationMailer.with(email: normalized_email, code: code).verification_code.deliver_now
      IssueResult.new(status: :sent)
    end

    def generate_code
      format(CODE_FORMAT, SecureRandom.random_number(1_000_000))
    end

    def normalize_email(email)
      email.to_s.strip.downcase
    end
  end
end
