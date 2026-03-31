class AnalyticsController < ApplicationController
  before_action :require_admin_or_staff

  AVAILABLE_HOURS_PER_DAY = 14 # 08:00–22:00
  DAY_NAMES = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze

  def show
    parse_date_range

    base_scope = Booking.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
    venue_bookings = base_scope.where.not(venue_id: nil).joins(:venue)

    # --- Day 1 charts ---
    @venue_booking_counts = venue_bookings.group("venues.name").count
    @status_counts = base_scope.group(:status).count.transform_keys { |k| k.to_s.titleize }

    @daily_bookings = base_scope.group("DATE(created_at)")
                                .count
                                .sort_by { |date, _| date }
                                .to_h

    @peak_hours = base_scope.where.not(start_time: nil)
                            .pluck(:start_time)
                            .map { |t| t.hour }
                            .tally
                            .sort_by { |hour, _| hour }
                            .to_h

    # --- Day 2: duration & occupancy ---
    compute_venue_duration_stats(venue_bookings)

    # --- Day 3: weekly breakdown + day-of-week + peak hours per venue ---
    compute_weekly_breakdown(base_scope)
    compute_day_of_week_distribution(base_scope)
    compute_peak_hours_by_venue(venue_bookings)

    compute_summary_stats(base_scope)
  end

  private

  def parse_date_range
    @start_date = if params[:start_date].present?
                    Date.parse(params[:start_date])
                  else
                    30.days.ago.to_date
                  end
    @end_date = if params[:end_date].present?
                  Date.parse(params[:end_date])
                else
                  Date.current
                end
    # Prevent reversed ranges
    @start_date, @end_date = @end_date, @start_date if @start_date > @end_date
  rescue ArgumentError
    @start_date = 30.days.ago.to_date
    @end_date = Date.current
  end

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

    days_in_period = [(@end_date - @start_date).to_i + 1, 1].max
    max_capacity = AVAILABLE_HOURS_PER_DAY * days_in_period
    @venue_occupancy_pct = @venue_duration_hours.transform_values do |hours|
      max_capacity.positive? ? (hours / max_capacity * 100).round(1) : 0
    end
  end

  def compute_weekly_breakdown(base_scope)
    weekly_data = base_scope.group("DATE(created_at)").count
    @weekly_bookings = {}
    weekly_data.each do |date, count|
      d = date.is_a?(String) ? Date.parse(date) : date
      week_label = "#{d.cweek}/#{d.cwyear}"
      @weekly_bookings[week_label] ||= 0
      @weekly_bookings[week_label] += count
    end
  end

  def compute_day_of_week_distribution(base_scope)
    times = base_scope.where.not(start_time: nil).pluck(:start_time)
    tally = times.map { |t| t.wday }.tally
    @day_of_week = DAY_NAMES.each_with_index.map { |name, i| [name, tally[i] || 0] }.to_h
  end

  def compute_peak_hours_by_venue(venue_bookings)
    rows = venue_bookings
             .where.not(start_time: nil)
             .select("venues.name AS venue_name, bookings.start_time")

    grid = Hash.new { |h, k| h[k] = Hash.new(0) }
    rows.each { |r| grid[r.venue_name][r.start_time.hour] += 1 }

    @heatmap_venues = grid.keys.sort
    @heatmap_hours = (8..21).to_a
    @heatmap_data = @heatmap_venues.map do |venue|
      @heatmap_hours.map { |h| grid[venue][h] }
    end
  end

  def compute_summary_stats(base_scope)
    @total_bookings = base_scope.count
    @pending_count  = base_scope.pending.count
    @approved_count = base_scope.approved.count
    @venues_count   = Venue.count
  end
end
