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

    rejected_status = Booking.statuses["rejected"]
    rejected_status ? scope.where.not(status: rejected_status) : scope
  end
end
