class User < ApplicationRecord
  has_secure_password

  has_many :bookings, dependent: :destroy
  has_many :venue_bookings, class_name: "VenueBooking", dependent: :destroy
  has_many :equipment_bookings, class_name: "EquipmentBooking", dependent: :destroy
  has_many :approval_steps, foreign_key: :actor_id, inverse_of: :actor, dependent: :restrict_with_exception
  has_many :api_keys, dependent: :destroy

  enum :role, { student: 0, staff: 1, admin: 2 }

  belongs_to :tenant, optional: true

  scope :root_accounts, -> { where(is_root_account: true) }

  before_validation :sync_college_scope_slug_from_tenant, if: :staff_with_tenant?

  def root_account?
    is_root_account
  end

  CUHK_EMAIL_REGEX = /\A[a-zA-Z0-9._%+-]+@link\.cuhk\.edu\.hk\z/i

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: CUHK_EMAIL_REGEX,
                              message: "must be a valid @link.cuhk.edu.hk address" }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
  validates :password_confirmation, presence: true, if: :new_record?
  validates :college_scope_slug, presence: true, if: :staff_with_tenant?
  validate :college_scope_slug_matches_tenant_slug, if: :staff_with_tenant?

  normalizes :email, with: ->(email) { email.strip.downcase }

  private

  def staff_with_tenant?
    staff? && tenant.present?
  end

  def sync_college_scope_slug_from_tenant
    self.college_scope_slug = tenant.slug
  end

  def college_scope_slug_matches_tenant_slug
    return if college_scope_slug == tenant.slug

    errors.add(:college_scope_slug, "must match the tenant scope")
  end
end
