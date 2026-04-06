class Tenant < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :equipment, dependent: :destroy

  enum :approval_mode, { one_step: 0, two_step: 1 }, default: :one_step

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :approval_mode, presence: true

  scope :university, -> { where("name LIKE '%niversity%' OR name LIKE '%NIVERSITY%'").or(where(slug: "university")) }

  def self.university_tenant_ids
    university.select(:id)
  end
end
