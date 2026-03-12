class User < ApplicationRecord
  has_secure_password

  ROLES = %w[student staff admin].freeze

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: ROLES }

  def student?
    role == "student"
  end

  def staff?
    role == "staff"
  end

  def admin?
    role == "admin"
  end

  def self.find_by_email_case_insensitive(email)
    where("LOWER(email) = ?", email.downcase).first
  end
end
