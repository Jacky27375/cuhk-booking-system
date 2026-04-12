class VenueBooking < Booking
  EXPIRED_PENDING_REJECTION_REASON = "Booking date has passed".freeze
  MAX_DAILY_BOOKINGS_PER_STUDENT = 2

  def self.model_name
    Booking.model_name
  end

  def self.reject_expired_pending!(at: Time.current)
    pending
      .where("end_time < ?", at)
      .find_each do |booking|
        booking.reject!(EXPIRED_PENDING_REJECTION_REASON)
      end
  end

  validates :venue, presence: true
  validates :start_time, :end_time, presence: true
  validate :venue_booking_time_rules
  validate :venue_accessible_by_user
  validate :no_time_conflict
  validate :advance_booking_limit
  validate :booking_duration_limit
  validate :daily_booking_limit_per_student

  private

  def venue_accessible_by_user
    return unless user && venue

    return if BookingAccessPolicy.venue_accessible?(user, venue)

    errors.add(:venue, "is not accessible to your college")
  end

  def venue_booking_time_rules
    return unless start_time.present? && end_time.present?

    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
      return
    end

    if start_time.to_date != end_time.to_date
      errors.add(:end_time, "must be on the same date as start time")
    end

    unless start_time.min.zero? && end_time.min.zero?
      errors.add(:base, "must start and end on the hour")
    end

    day_start = Time.zone.local(start_time.year, start_time.month, start_time.day, 8, 0, 0)
    day_end = Time.zone.local(start_time.year, start_time.month, start_time.day, 22, 0, 0)
    if start_time < day_start || end_time > day_end
      errors.add(:base, "must be between 08:00 and 22:00")
    end
  end

  def no_time_conflict
    return unless venue_id.present? && start_time.present? && end_time.present?

    errors.add(:base, "conflicts with an existing booking") if BookingConflictChecker.new(self).conflict_exists?
  end

  def advance_booking_limit
    return unless start_time.present? && pending?

    # Booking must be at least 5 days in advance
    if start_time.to_date < 5.days.from_now.to_date
      errors.add(:base, "Venue must be booked at least 5 days in advance")
    end
  end

  def booking_duration_limit
    return unless start_time.present? && end_time.present?

    duration_hours = ((end_time - start_time) / 3600).round
    if duration_hours > 4
      errors.add(:base, "Booking duration cannot exceed 4 hours")
    end
  end

  def daily_booking_limit_per_student
    return unless user&.student?
    return unless start_time.present?
    return if status.in?(Booking::NON_BLOCKING_VENUE_STATUSES)

    booking_date = start_time.to_date
    day_start = booking_date.beginning_of_day
    day_end = booking_date.end_of_day

    existing_count = user.venue_bookings
                         .where.not(status: Booking.non_blocking_venue_status_values)
                         .where(start_time: day_start..day_end)
                         .where.not(id: id)
                         .count

    if existing_count >= MAX_DAILY_BOOKINGS_PER_STUDENT
      errors.add(:base, "You can book at most 2 venues per day")
    end
  end
end
