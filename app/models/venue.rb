class Venue < ApplicationRecord
  belongs_to :tenant, optional: true

  has_many :bookings, dependent: :destroy
  validates :name, :department, presence: true

  scope :visible_to_tenant, lambda { |tenant|
    return none unless tenant

    where(tenant_id: tenant.id).or(where(tenant_id: nil, department: tenant.name))
  }

  def accessible_by_tenant?(tenant)
    return false unless tenant

    tenant_id.present? ? tenant_id == tenant.id : department == tenant.name
  end
end
