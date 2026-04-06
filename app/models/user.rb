class User < ApplicationRecord
  has_secure_password

  has_many :bookings, dependent: :destroy
  has_many :venue_bookings, class_name: "VenueBooking", dependent: :destroy
  has_many :equipment_bookings, class_name: "EquipmentBooking", dependent: :destroy
  has_many :approval_steps, foreign_key: :actor_id, inverse_of: :actor, dependent: :restrict_with_exception
  has_many :api_keys, dependent: :destroy

  enum :role, { society_member: 0, staff: 1, admin: 2 }

  belongs_to :tenant, optional: true

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }

  normalizes :email, with: ->(email) { email.strip.downcase }
end
