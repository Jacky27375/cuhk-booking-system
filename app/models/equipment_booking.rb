class EquipmentBooking < Booking
  def self.model_name
    Booking.model_name
  end

  validates :equipment, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :start_date, :end_date, presence: true
  validate :equipment_accessible_by_user
  validate :equipment_quantity_available
  validate :advance_booking_limit
  validate :booking_duration_limit

  private

  def equipment_accessible_by_user
    return unless user && equipment

    return if BookingAccessPolicy.equipment_accessible?(user, equipment)

    errors.add(:equipment, "is not accessible to your college")
  end

  def equipment_quantity_available
    return unless equipment && quantity.present?
    return unless status.in?(Equipment::INVENTORY_HOLDING_STATUSES)

    available_quantity = equipment.available_quantity(excluding_booking_id: id)
    errors.add(:base, "Not enough units available") if quantity > available_quantity
  end

  def advance_booking_limit
    return unless start_date.present?

    # Booking must be at least 5 days in advance
    if start_date < 5.days.from_now.to_date
      errors.add(:base, "Equipment must be booked at least 5 days in advance")
    end
  end

  def booking_duration_limit
    return unless start_date.present? && end_date.present?

    duration_days = (end_date - start_date).to_i
    if duration_days > 7
      errors.add(:base, "Equipment booking duration cannot exceed 7 days")
    end
  end
end
