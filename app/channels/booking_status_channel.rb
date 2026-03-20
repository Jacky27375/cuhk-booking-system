class BookingStatusChannel < ApplicationCable::Channel
  def subscribed
    stream_from "booking_status_user_#{current_user.id}"
  end
end
