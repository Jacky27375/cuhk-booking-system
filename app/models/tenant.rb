class Tenant < ApplicationRecord
  has_many :users, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end
