class VenueBooking < Booking
  def self.model_name
    Booking.model_name
  end

  validates :venue, presence: true
  validates :start_time, :end_time, presence: true
  validate :venue_booking_time_rules
  validate :venue_accessible_by_user
  validate :no_time_conflict
  validate :advance_booking_limit
  validate :booking_duration_limit

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
    return unless start_time.present?

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
end
