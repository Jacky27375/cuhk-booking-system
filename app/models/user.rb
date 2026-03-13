class User < ApplicationRecord
  has_secure_password

  enum :role, { society_member: 0, staff: 1, admin: 2 }

  belongs_to :tenant, optional: true
  belongs_to :society, optional: true

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }

  normalizes :email, with: ->(email) { email.strip.downcase }
end
