class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :equipment

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :start_date, :end_date, presence: true

  after_initialize :set_default_status, if: :new_record?

  private

  def set_default_status
    self.status ||= "pending"
  end
end
