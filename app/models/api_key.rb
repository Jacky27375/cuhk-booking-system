class ApiKey < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :name, presence: true

  before_validation :generate_token, on: :create

  scope :active, -> { where(active: true).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def usable?
    active? && !expired?
  end

  def touch_last_used!
    update_column(:last_used_at, Time.current)
  end

  private

  def generate_token
    self.token ||= SecureRandom.hex(32)
  end
end
