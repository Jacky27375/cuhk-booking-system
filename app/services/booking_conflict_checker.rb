class BookingConflictChecker
  def initialize(booking)
    @booking = booking
  end

  def conflict_exists?
    conflicting_bookings.exists?
  end

  private

  attr_reader :booking

  def conflicting_bookings
    scope = Booking.where(venue_id: booking.venue_id)
                   .where.not(id: booking.id)
                   .where("start_time < ? AND end_time > ?", booking.end_time, booking.start_time)

    return scope unless Booking.defined_enums.key?("status")

    non_blocking_statuses = Booking.non_blocking_venue_status_values
    non_blocking_statuses.any? ? scope.where.not(status: non_blocking_statuses) : scope
  end
end
