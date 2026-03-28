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
      joins_clause = left_outer_joins(:venue, :equipment)
      q1 = joins_clause.where(venues: { tenant_id: tenant.id })
      q2 = if Venue.legacy_department_fallback_enabled?
             q1.or(joins_clause.where(venues: { tenant_id: nil, department: tenant.name }))
           else
             q1
           end
      q2.or(joins_clause.where(equipment: { tenant_id: tenant.id }))
    else
      joins_clause = left_outer_joins(:venue)
      q1 = joins_clause.where(venues: { tenant_id: tenant.id })
      if Venue.legacy_department_fallback_enabled?
        q1.or(joins_clause.where(venues: { tenant_id: nil, department: tenant.name }))
      else
        q1
      end
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
      accessible = if user.admin?
                     true
                   elsif user.staff?
                     venue.accessible_by_tenant?(user.tenant)
                   else
                     # student can access their tenant's venues and university venues
                     tenant_ids = [user.tenant_id].compact + Tenant.university_tenant_ids.map(&:id)
                     if venue.tenant_id && venue.tenant_id.in?(tenant_ids)
                       true
                     elsif venue.tenant && venue.tenant == user.tenant
                       true
                     elsif Venue.legacy_department_fallback_enabled? && user.tenant && venue.tenant_id.nil? && venue.department == user.tenant.name
                       true
                     else
                       false
                     end
                   end

      unless accessible
        errors.add(:venue, "is not accessible to your college")
      end
    end

    if respond_to?(:equipment) && equipment.present?
      unless user.admin? || (user.tenant && equipment.tenant_id == user.tenant_id) || (Equipment.method_defined?(:visible_to_student) && Equipment.visible_to_user(user).exists?(id: equipment_id))
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
