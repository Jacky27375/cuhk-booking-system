class AnalyticsController < ApplicationController
  before_action :require_admin_or_staff

  AVAILABLE_HOURS_PER_DAY = 14 # 08:00–22:00

  def show
    venue_bookings = Booking.where.not(venue_id: nil).joins(:venue)

    # --- Day 1 charts ---
    @venue_booking_counts = venue_bookings.group("venues.name").count

    @status_counts = Booking.group(:status).count.transform_keys { |k| k.to_s.titleize }

    recent_bookings = Booking.where("created_at >= ?", 30.days.ago)
    @daily_bookings = recent_bookings.group("DATE(created_at)")
                                     .count
                                     .sort_by { |date, _| date }
                                     .to_h

    @peak_hours = Booking.where.not(start_time: nil)
                         .pluck(:start_time)
                         .map { |t| t.hour }
                         .tally
                         .sort_by { |hour, _| hour }
                         .to_h

    # --- Day 2: duration & occupancy ---
    compute_venue_duration_stats(venue_bookings)
    compute_summary_stats
  end

  private

  def compute_venue_duration_stats(venue_bookings)
    rows = venue_bookings
             .where.not(start_time: nil, end_time: nil)
             .select("venues.name AS venue_name, bookings.start_time, bookings.end_time")

    duration_by_venue = Hash.new(0.0)
    rows.each do |row|
      hours = (row.end_time - row.start_time) / 1.hour
      duration_by_venue[row.venue_name] += hours
    end
    @venue_duration_hours = duration_by_venue.sort_by { |_, v| -v }.to_h

    # Occupancy rate: booked hours / (available hours × operating days in last 30 days)
    days_in_period = 30
    max_capacity = AVAILABLE_HOURS_PER_DAY * days_in_period # per venue
    @venue_occupancy_pct = @venue_duration_hours.transform_values do |hours|
      max_capacity.positive? ? (hours / max_capacity * 100).round(1) : 0
    end
  end

  def compute_summary_stats
    @total_bookings = Booking.count
    @pending_count  = Booking.pending.count
    @approved_count = Booking.approved.count
    @venues_count   = Venue.count
  end
end
