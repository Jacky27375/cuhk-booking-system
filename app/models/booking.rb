class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :equipment, optional: true
  belongs_to :venue, optional: true

  enum :status, { pending: 0, approved: 1, rejected: 2, borrowed: 3, returned: 4 }

  after_initialize :set_default_status, if: :new_record?
  after_update_commit :broadcast_status_change, if: :saved_change_to_status?

  scope :venue_bookings, -> { where(type: "VenueBooking") }
  scope :equipment_bookings, -> { where(type: "EquipmentBooking") }
  scope :for_tenant, ->(tenant) { BookingScopeQuery.for_tenant(tenant) }

  def approve!
    update!(status: :approved, rejection_reason: nil)
  end

  def reject!(reason)
    update!(status: :rejected, rejection_reason: reason)
  end

  def self.build_for_venue(attributes = {})
    VenueBooking.new(attributes)
  end

  def self.build_for_equipment(attributes = {})
    EquipmentBooking.new(attributes)
  end

  def to_partial_path
    "bookings/booking"
  end

  private

  def set_default_status
    self.status ||= "pending"
  end

  def broadcast_status_change
    ActionCable.server.broadcast(
      "booking_status_user_#{user_id}",
      { booking_id: id, status: status, status_label: status.titleize }
    )
  end
end
