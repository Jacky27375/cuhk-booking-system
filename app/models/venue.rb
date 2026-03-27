class Venue < ApplicationRecord
  belongs_to :tenant, optional: true

  has_many :bookings, dependent: :destroy
  validates :name, :department, presence: true

  scope :visible_to_user, lambda { |user|
    return none unless user
    return all if user.admin?

    if user.tenant
      visible_to_tenant(user.tenant)
    else
      where(tenant_id: nil)
    end
  }

  scope :visible_to_tenant, lambda { |tenant|
    return none unless tenant

    scoped = where(tenant_id: tenant.id)
    if legacy_department_fallback_enabled?
      scoped.or(where(tenant_id: nil, department: tenant.name))
    else
      scoped
    end
  }

  def accessible_by_tenant?(tenant)
    return false unless tenant

    return tenant_id == tenant.id if tenant_id.present?

    self.class.legacy_department_fallback_enabled? && department == tenant.name
  end

  def self.legacy_department_fallback_enabled?
    ActiveModel::Type::Boolean.new.cast(
      ENV.fetch("ALLOW_LEGACY_TENANT_DEPARTMENT_FALLBACK", "true")
    )
  end
end
