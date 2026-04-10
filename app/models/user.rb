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
  CUHK_EMAIL_DOMAIN = "link.cuhk.edu.hk"
  CUHK_EMAIL_REGEX = /\A[a-zA-Z0-9._%+-]+@#{Regexp.escape(CUHK_EMAIL_DOMAIN)}\z/i

  def root_account?
    is_root_account
  end

  def root_staff_account?
    staff? && root_account?
  end

  def deletable_by_admin?(acting_admin)
    return false if acting_admin == self
    return false if admin? && User.admin.count <= 1

    true
  end

  def active_session_locked?
    active_session_token.present?
  end

  def issue_active_session_token!
    token = SecureRandom.hex(SESSION_TOKEN_LENGTH / 2)
    update!(active_session_token: token)
    token
  end

  def clear_active_session_token!(token:)
    return unless active_session_token_matches?(token)

    update!(active_session_token: nil)
  end

  def active_session_token_matches?(token)
    submitted_token = token.to_s
    return false if active_session_token.blank? || submitted_token.blank?

    ActiveSupport::SecurityUtils.secure_compare(active_session_token, submitted_token)
  end

  def self.canonicalize_cuhk_email(local_part_or_email)
    value = local_part_or_email.to_s.strip.downcase
    return "" if value.blank?

    local_part = value.split("@", 2).first
    return "" if local_part.blank?

    "#{local_part}@#{CUHK_EMAIL_DOMAIN}"
  end

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: CUHK_EMAIL_REGEX,
                              message: "must be a valid @link.cuhk.edu.hk address" }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
  validates :password_confirmation, presence: true, if: :new_record?

  normalizes :email, with: ->(email) { email.strip.downcase }
end
