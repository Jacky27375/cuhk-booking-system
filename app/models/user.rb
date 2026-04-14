class User < ApplicationRecord
  has_secure_password

  has_many :bookings, dependent: :destroy
  has_many :venue_bookings, class_name: "VenueBooking", dependent: :destroy
  has_many :equipment_bookings, class_name: "EquipmentBooking", dependent: :destroy
  has_many :requested_venue_requests, class_name: "VenueRequest", foreign_key: :requester_id, inverse_of: :requester, dependent: :restrict_with_exception
  has_many :reviewed_venue_requests, class_name: "VenueRequest", foreign_key: :reviewed_by_id, inverse_of: :reviewed_by, dependent: :nullify
  has_many :approval_steps, foreign_key: :actor_id, inverse_of: :actor, dependent: :restrict_with_exception
  has_many :api_keys, dependent: :destroy

  enum :role, { student: 0, staff: 1, admin: 2 }

  belongs_to :tenant, optional: true

  scope :root_accounts, -> { where(is_root_account: true) }

  SESSION_TOKEN_LENGTH = 64
  DEFAULT_ACTIVE_SESSION_LOCK_TIMEOUT = 12.hours
  DEFAULT_ACTIVE_SESSION_LOCK_TOUCH_INTERVAL = 5.minutes
  CUHK_EMAIL_DOMAIN = "link.cuhk.edu.hk"
  CUHK_EMAIL_REGEX = /\A[a-zA-Z0-9._%+-]+@#{Regexp.escape(CUHK_EMAIL_DOMAIN)}\z/i
  PASSWORD_MIN_LENGTH = 10
  PASSWORD_COMPLEXITY_REGEX = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).+\z/
  PASSWORD_COMPLEXITY_MESSAGE = "must include at least one uppercase letter, one lowercase letter, one number, and one symbol"
  PASSWORD_UPPERCASE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ"
  PASSWORD_LOWERCASE_CHARS = "abcdefghijkmnopqrstuvwxyz"
  PASSWORD_DIGIT_CHARS = "23456789"
  PASSWORD_SYMBOL_CHARS = "!@#$%^&*()-_=+[]{}?"

  def root_account?
    is_root_account
  end

  def root_staff_account?
    staff? && root_account?
  end

  def deletable_by_admin?(acting_admin)
    return false if acting_admin == self
    return false if root_staff_account?
    return false if admin? && User.admin.count <= 1

    true
  end

  def self.active_session_lock_timeout
    timeout_seconds = ENV.fetch("ACTIVE_SESSION_LOCK_TIMEOUT_SECONDS", DEFAULT_ACTIVE_SESSION_LOCK_TIMEOUT.to_i).to_i
    timeout_seconds = DEFAULT_ACTIVE_SESSION_LOCK_TIMEOUT.to_i if timeout_seconds <= 0
    timeout_seconds.seconds
  end

  def self.active_session_lock_touch_interval
    interval_seconds = ENV.fetch("ACTIVE_SESSION_LOCK_TOUCH_INTERVAL_SECONDS", DEFAULT_ACTIVE_SESSION_LOCK_TOUCH_INTERVAL.to_i).to_i
    interval_seconds = DEFAULT_ACTIVE_SESSION_LOCK_TOUCH_INTERVAL.to_i if interval_seconds <= 0
    interval_seconds.seconds
  end

  def active_session_locked?(reference_time: Time.current)
    active_session_token.present? && !active_session_lock_expired?(reference_time: reference_time)
  end

  def issue_active_session_token!(issued_at: Time.current)
    token = SecureRandom.hex(SESSION_TOKEN_LENGTH / 2)
    update!(active_session_token: token, active_session_token_issued_at: issued_at)
    token
  end

  def clear_active_session_token!(token:)
    return unless active_session_token_matches?(token)

    clear_active_session_lock!
  end

  def clear_expired_active_session_lock!(reference_time: Time.current)
    return false unless active_session_lock_expired?(reference_time: reference_time)

    clear_active_session_lock!
    true
  end

  def touch_active_session_lock!(token:, reference_time: Time.current)
    return false unless active_session_token_matches?(token)
    return false if active_session_lock_expired?(reference_time: reference_time)
    return false if active_session_token_issued_at.present? &&
                    active_session_token_issued_at >= (reference_time - self.class.active_session_lock_touch_interval)

    update!(active_session_token_issued_at: reference_time)
    true
  end

  def active_session_token_matches?(token)
    submitted_token = token.to_s
    return false if active_session_token.blank? || submitted_token.blank?

    ActiveSupport::SecurityUtils.secure_compare(active_session_token, submitted_token)
  end

  def active_session_lock_expired?(reference_time: Time.current)
    return false if active_session_token.blank?

    issued_at = active_session_token_issued_at
    return true if issued_at.blank?

    issued_at <= (reference_time - self.class.active_session_lock_timeout)
  end

  def self.canonicalize_cuhk_email(local_part_or_email)
    value = local_part_or_email.to_s.strip.downcase
    return "" if value.blank?

    local_part = value.split("@", 2).first
    return "" if local_part.blank?

    "#{local_part}@#{CUHK_EMAIL_DOMAIN}"
  end

  def self.generate_compliant_password(length: 14)
    target_length = [length.to_i, PASSWORD_MIN_LENGTH].max
    required_sets = [
      PASSWORD_UPPERCASE_CHARS,
      PASSWORD_LOWERCASE_CHARS,
      PASSWORD_DIGIT_CHARS,
      PASSWORD_SYMBOL_CHARS
    ]

    password_characters = required_sets.map { |set| random_password_character(set) }
    all_characters = required_sets.join

    while password_characters.length < target_length
      password_characters << random_password_character(all_characters)
    end

    secure_shuffle(password_characters).join
  end

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: CUHK_EMAIL_REGEX,
                              message: "must be a valid @link.cuhk.edu.hk address" }
  validates :password, length: { minimum: PASSWORD_MIN_LENGTH }, if: :password_validation_required?
  validate :password_must_meet_complexity_requirements, if: :password_validation_required?
  validates :password_confirmation, presence: true, if: :new_record?

  normalizes :email, with: ->(email) { email.strip.downcase }

  private

  def self.random_password_character(characters)
    characters[SecureRandom.random_number(characters.length)]
  end
  private_class_method :random_password_character

  def self.secure_shuffle(values)
    shuffled_values = values.dup

    (shuffled_values.length - 1).downto(1) do |index|
      swap_index = SecureRandom.random_number(index + 1)
      shuffled_values[index], shuffled_values[swap_index] = shuffled_values[swap_index], shuffled_values[index]
    end

    shuffled_values
  end
  private_class_method :secure_shuffle

  def password_validation_required?
    new_record? || password.present?
  end

  def password_must_meet_complexity_requirements
    return if password.to_s.match?(PASSWORD_COMPLEXITY_REGEX)

    errors.add(:password, PASSWORD_COMPLEXITY_MESSAGE)
  end

  def clear_active_session_lock!
    update!(active_session_token: nil, active_session_token_issued_at: nil)
  end
end
