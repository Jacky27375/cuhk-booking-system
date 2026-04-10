class ExpirePendingVenueBookingsJob < ApplicationJob
  queue_as :default

  def perform
    VenueBooking.reject_expired_pending!
  end
end
