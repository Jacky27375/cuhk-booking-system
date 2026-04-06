class Booking < ApplicationRecord
  APPROVABLE_FROM_STATUSES = %w[pending].freeze
  REJECTABLE_FROM_STATUSES = %w[pending].freeze
  RETURNABLE_EQUIPMENT_STATUSES = %w[approved borrowed].freeze

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
    transition_status!(
      target_status: :approved,
      allowed_from: APPROVABLE_FROM_STATUSES,
      extra_attributes: { rejection_reason: nil }
    )
  end

  def reject!(reason)
    transition_status!(
      target_status: :rejected,
      allowed_from: REJECTABLE_FROM_STATUSES,
      extra_attributes: { rejection_reason: reason }
    )
  end

  def mark_returned!
    unless equipment.present?
      errors.add(:status, "can only be marked as returned for equipment bookings")
      raise ActiveRecord::RecordInvalid, self
    end

    transition_status!(
      target_status: :returned,
      allowed_from: RETURNABLE_EQUIPMENT_STATUSES
    )
  end

  def returnable?
    equipment.present? && status.in?(RETURNABLE_EQUIPMENT_STATUSES)
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

  def transition_status!(target_status:, allowed_from:, extra_attributes: {})
    current_status = status
    unless allowed_from.include?(current_status)
      errors.add(:status, "cannot transition from #{current_status} to #{target_status}")
      raise ActiveRecord::RecordInvalid, self
    end

    update!({ status: target_status }.merge(extra_attributes))
  end
end
