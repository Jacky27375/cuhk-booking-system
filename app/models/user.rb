class User < ApplicationRecord
  has_secure_password

  has_many :bookings, dependent: :destroy
  has_many :venue_bookings, class_name: "VenueBooking", dependent: :destroy
  has_many :equipment_bookings, class_name: "EquipmentBooking", dependent: :destroy
  has_many :api_keys, dependent: :destroy

  enum :role, { society_member: 0, staff: 1, admin: 2 }

  belongs_to :tenant, optional: true

  CUHK_EMAIL_REGEX = /\A[a-zA-Z0-9._%+-]+@link\.cuhk\.edu\.hk\z/i

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: CUHK_EMAIL_REGEX,
                              message: "must be a valid @link.cuhk.edu.hk address" }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
  validates :password_confirmation, presence: true, if: :new_record?

  normalizes :email, with: ->(email) { email.strip.downcase }
end
