class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :equipment, optional: true
  belongs_to :venue, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0 }, if: -> { equipment_id.present? }
  validates :start_date, :end_date, presence: true, if: -> { equipment_id.present? }
  validates :start_time, :end_time, presence: true, if: -> { venue_id.present? }
  validate :user_can_access_resource
  validate :venue_booking_time_rules
  validate :no_time_conflict

  enum :status, { pending: 0, approved: 1, rejected: 2, borrowed: 3, returned: 4 }

  validate :equipment_quantity_available, if: -> { equipment_id.present? && quantity.present? }

  after_initialize :set_default_status, if: :new_record?
  after_update_commit :broadcast_status_change, if: :saved_change_to_status?

  scope :for_tenant, ->(tenant) { BookingScopeQuery.for_tenant(tenant) }

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

    if venue.present? && !BookingAccessPolicy.venue_accessible?(user, venue)
      errors.add(:venue, "is not accessible to your college")
    end

    if equipment.present? && !BookingAccessPolicy.equipment_accessible?(user, equipment)
      errors.add(:equipment, "is not accessible to your college")
    end
  end

  def venue_booking_time_rules
    return unless venue_id.present?
    return unless start_time.present? && end_time.present?

    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
      return
    end

    if start_time.to_date != end_time.to_date
      errors.add(:end_time, "must be on the same date as start time")
    end

    unless start_time.min.zero? && end_time.min.zero?
      errors.add(:base, "must start and end on the hour")
    end

    day_start = Time.zone.local(start_time.year, start_time.month, start_time.day, 8, 0, 0)
    day_end = Time.zone.local(start_time.year, start_time.month, start_time.day, 22, 0, 0)
    if start_time < day_start || end_time > day_end
      errors.add(:base, "must be between 08:00 and 22:00")
    end
  end

  def no_time_conflict
    return unless venue_id.present? && start_time.present? && end_time.present?

    errors.add(:base, "conflicts with an existing booking") if BookingConflictChecker.new(self).conflict_exists?
  end

  def equipment_quantity_available
    return unless equipment

    if quantity > equipment.available_quantity
      errors.add(:base, "Not enough units available")
    end
  end

  def broadcast_status_change
    ActionCable.server.broadcast(
      "booking_status_user_#{user_id}",
      { booking_id: id, status: status, status_label: status.titleize }
    )
  end
end
