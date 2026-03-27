class Tenant < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :equipment, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end
