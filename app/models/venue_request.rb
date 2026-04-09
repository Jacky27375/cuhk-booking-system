class VenueRequest < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :tenant
  belongs_to :reviewed_by, class_name: "User", optional: true

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :venue_name, presence: true
  validate :requester_must_be_staff

  def approve!(admin)
    transaction do
      update!(status: :approved, reviewed_by: admin, reviewed_at: Time.current)
      Venue.create!(name: venue_name, description: description, department: tenant.name, tenant: tenant)
    end
  end

  def reject!(admin, reason:)
    update!(status: :rejected, reviewed_by: admin, reviewed_at: Time.current, rejection_reason: reason)
  end

  private

  def requester_must_be_staff
    errors.add(:requester, "must be staff") unless requester&.staff? || requester&.admin?
  end
end
