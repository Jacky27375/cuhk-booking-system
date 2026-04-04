require "rails_helper"

RSpec.describe "analytics/show", type: :view do
  let(:tenant) { create(:tenant, name: "University", slug: "university") }

  before do
    assign(:start_date, 30.days.ago.to_date)
    assign(:end_date, Date.current)
    assign(:total_bookings, 10)
    assign(:pending_count, 3)
    assign(:approved_count, 5)
    assign(:venues_count, 4)
    assign(:equipment_count, 2)
    assign(:venue_booking_counts, { "Room A" => 5, "Room B" => 3 })
    assign(:status_counts, { "Pending" => 3, "Approved" => 5, "Rejected" => 2 })
    assign(:daily_bookings, { Date.current => 4, 1.day.ago.to_date => 6 })
    assign(:peak_hours, { 10 => 5, 14 => 3 })
    assign(:venue_duration_hours, { "Room A" => 8.5, "Room B" => 4.0 })
    assign(:venue_occupancy_pct, { "Room A" => 12.3, "Room B" => 6.1 })
    assign(:weekly_bookings, { "14/2026" => 7 })
    assign(:day_of_week, { "Monday" => 2, "Tuesday" => 3, "Wednesday" => 5, "Thursday" => 0, "Friday" => 0, "Saturday" => 0, "Sunday" => 0 })
    assign(:equipment_borrow_counts, { "Projector" => 3 })
    assign(:equipment_quantity_borrowed, { "Projector" => 6 })
    assign(:equipment_status_counts, { "Pending" => 1, "Approved" => 2 })
    assign(:heatmap_venues, ["Room A"])
    assign(:heatmap_hours, (8..21).to_a)
    assign(:heatmap_data, [(8..21).map { |h| h == 10 ? 5 : 0 }])
  end

  it "renders the analytics dashboard heading" do
    render
    expect(rendered).to include("Analytics Dashboard")
  end

  it "renders summary stat cards" do
    render
    expect(rendered).to include("Total Bookings")
    expect(rendered).to include("10")
    expect(rendered).to include("Pending")
    expect(rendered).to include("3")
    expect(rendered).to include("Approved")
    expect(rendered).to include("5")
  end

  it "renders the date range filter form" do
    render
    expect(rendered).to have_selector("input[name='start_date']")
    expect(rendered).to have_selector("input[name='end_date']")
    expect(rendered).to include("Filter")
    expect(rendered).to include("Reset")
  end

  it "renders venue booking chart container" do
    render
    expect(rendered).to include("Bookings per Venue")
    expect(rendered).to have_selector("[data-controller='chart'][data-chart-type-value='bar']")
  end

  it "renders status distribution chart" do
    render
    expect(rendered).to include("Booking Status Distribution")
    expect(rendered).to have_selector("[data-controller='chart'][data-chart-type-value='doughnut']")
  end

  it "renders venue duration chart" do
    render
    expect(rendered).to include("Total Booked Hours per Venue")
  end

  it "renders venue occupancy chart" do
    render
    expect(rendered).to include("Venue Occupancy Rate")
  end

  it "renders daily trend chart" do
    render
    expect(rendered).to include("Daily Bookings Trend")
  end

  it "renders peak hours chart" do
    render
    expect(rendered).to include("Peak Booking Hours")
  end

  it "renders weekly trend chart" do
    render
    expect(rendered).to include("Weekly Booking Trend")
  end

  it "renders day-of-week chart" do
    render
    expect(rendered).to include("Bookings by Day of Week")
  end

  it "renders equipment borrow count chart" do
    render
    expect(rendered).to include("Equipment Borrow Count")
  end

  it "renders equipment quantity chart" do
    render
    expect(rendered).to include("Total Units Borrowed per Equipment")
  end

  it "renders equipment status chart" do
    render
    expect(rendered).to include("Equipment Booking Status")
  end

  it "renders peak hours by venue heatmap table" do
    render
    expect(rendered).to include("Peak Hours by Venue")
    expect(rendered).to have_selector("table")
    expect(rendered).to include("Room A")
  end

  it "renders the back link" do
    render
    expect(rendered).to have_link("← Back to Dashboard", href: dashboard_path)
  end

  context "with empty data" do
    before do
      assign(:venue_booking_counts, {})
      assign(:status_counts, {})
      assign(:daily_bookings, {})
      assign(:peak_hours, {})
      assign(:venue_duration_hours, {})
      assign(:venue_occupancy_pct, {})
      assign(:weekly_bookings, {})
      assign(:day_of_week, { "Monday" => 0, "Tuesday" => 0, "Wednesday" => 0, "Thursday" => 0, "Friday" => 0, "Saturday" => 0, "Sunday" => 0 })
      assign(:equipment_borrow_counts, {})
      assign(:equipment_quantity_borrowed, {})
      assign(:equipment_status_counts, {})
      assign(:heatmap_venues, [])
      assign(:heatmap_hours, [])
      assign(:heatmap_data, [])
    end

    it "shows empty state messages" do
      render
      expect(rendered).to include("No venue bookings yet.")
      expect(rendered).to include("No equipment borrowing data yet.")
      expect(rendered).to have_selector(".analytics-empty-state")
    end

    it "does not render the heatmap table" do
      render
      expect(rendered).not_to have_selector("table")
    end
  end
end
