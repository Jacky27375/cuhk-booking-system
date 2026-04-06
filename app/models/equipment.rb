class Equipment < ApplicationRecord
  INVENTORY_HOLDING_STATUSES = %w[pending approved borrowed].freeze
  self.table_name = "equipment"

  belongs_to :tenant
  has_many :bookings, dependent: :destroy
  has_many :equipment_bookings, class_name: "EquipmentBooking", dependent: :destroy

  validates :name, presence: true
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :visible_to_user, lambda { |user|
    return none unless user
    return all if user.admin?

    if user.staff?
      where(tenant_id: user.tenant_id)
    else
      visible_to_student(user)
    end
  }

  scope :visible_to_student, lambda { |user|
    return none unless user

    tenant_ids = [user.tenant_id].compact + Tenant.university_tenant_ids.map(&:id)
    where(tenant_id: tenant_ids.uniq)
  }

  def available_quantity(excluding_booking_id: nil)
    scope = bookings.where(status: INVENTORY_HOLDING_STATUSES)
    scope = scope.where.not(id: excluding_booking_id) if excluding_booking_id.present?

    quantity - scope.sum(:quantity)
  end
end
