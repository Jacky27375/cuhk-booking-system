class Equipment < ApplicationRecord
  belongs_to :tenant
  has_many :bookings, dependent: :destroy

  validates :name, presence: true
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def available_quantity
    booked_quantity = bookings.where(status: ['approved', 'borrowed']).sum(:quantity)
    quantity - booked_quantity
  end
end