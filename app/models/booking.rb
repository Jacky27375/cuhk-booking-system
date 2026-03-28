class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :equipment, optional: true
  belongs_to :venue, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0 }, if: -> { respond_to?(:equipment_id) && equipment_id.present? }
  validates :start_date, :end_date, presence: true, if: -> { respond_to?(:equipment_id) && equipment_id.present? }
  validates :start_time, :end_time, presence: true, if: -> { respond_to?(:venue_id) && venue_id.present? }
  validate :user_can_access_resource

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  after_initialize :set_default_status, if: :new_record?
  after_update_commit :broadcast_status_change, if: :saved_change_to_status?

  scope :for_tenant, lambda { |tenant|
    if column_names.include?("equipment_id")
      left_outer_joins(:venue, :equipment).where(
        venues: { tenant_id: tenant.id }
      ).or(
        left_outer_joins(:venue, :equipment).where(equipment: { tenant_id: tenant.id })
      )
    else
      left_outer_joins(:venue).where(venues: { tenant_id: tenant.id })
    end
  }

  def approve!
    update!(status: :approved, rejection_reason: nil)
  end

  def reject!(reason)
    update!(status: :rejected, rejection_reason: reason)
  end

  private

  def set_default_status
    self.status ||= "pending"
  end

  def user_can_access_resource
    return unless user

    if respond_to?(:venue) && venue.present?
      unless Venue.visible_to_user(user).exists?(id: venue_id)
        errors.add(:venue, "is not accessible to your college")
      end
    end

    if respond_to?(:equipment) && equipment.present?
      unless Equipment.visible_to_user(user).exists?(id: equipment_id)
        errors.add(:equipment, "is not accessible to your college")
      end
    end
  end

  def broadcast_status_change
    ActionCable.server.broadcast(
      "booking_status_user_#{user_id}",
      { booking_id: id, status: status, status_label: status.titleize }
    )
  end
end
