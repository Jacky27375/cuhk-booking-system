class Venue < ApplicationRecord
  belongs_to :tenant, optional: true

  has_many :bookings, dependent: :destroy
  validates :name, :department, presence: true

  scope :visible_to_user, lambda { |user|
    return none unless user
    return all if user.admin?

    if user.staff?
      # Staff can only see their exact tenant
      where(tenant_id: user.tenant_id)
    else
      # Students (society_member) can see their college + university
      visible_to_student(user)
    end
  }

  scope :visible_to_student, lambda { |user|
    return none unless user

    tenant_ids = [user.tenant_id].compact + Tenant.university_tenant_ids.map(&:id)
    where(tenant_id: tenant_ids.uniq)
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
