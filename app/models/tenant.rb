class Tenant < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :equipment, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :university, -> { where("name LIKE '%niversity%' OR name LIKE '%NIVERSITY%'").or(where(slug: 'university')) }
  
  def self.university_tenant_ids
    university.select(:id)
  end
end
