class EquipmentBooking < Booking
  def self.model_name
    Booking.model_name
  end

  validates :equipment, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :start_date, :end_date, presence: true
  validate :equipment_accessible_by_user
  validate :equipment_quantity_available

  private

  def equipment_accessible_by_user
    return unless user && equipment

    return if BookingAccessPolicy.equipment_accessible?(user, equipment)

    errors.add(:equipment, "is not accessible to your college")
  end

  def equipment_quantity_available
    return unless equipment && quantity.present?

    errors.add(:base, "Not enough units available") if quantity > equipment.available_quantity
  end
end