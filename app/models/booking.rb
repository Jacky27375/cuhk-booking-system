class Booking < ApplicationRecord
  belongs_to :venue
  belongs_to :user

  validates :start_time, :end_time, presence: true

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  after_update_commit :broadcast_status_change, if: :saved_change_to_status?

  def approve!
    update!(status: :approved, rejection_reason: nil)
  end

  def reject!(reason)
    update!(status: :rejected, rejection_reason: reason)
  end

  private

  def broadcast_status_change
    ActionCable.server.broadcast(
      "booking_status_user_#{user_id}",
      { booking_id: id, status: status.titleize }
    )
  end
end
