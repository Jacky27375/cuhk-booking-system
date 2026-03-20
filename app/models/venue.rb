class Venue < ApplicationRecord
  has_many :bookings, dependent: :destroy
  validates :name, :department, presence: true
end
