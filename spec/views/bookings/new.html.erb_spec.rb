require 'rails_helper'

RSpec.describe "bookings/new", type: :view do
  before(:each) do
    assign(:venues, [create(:venue, name: "Room 101", department: "Science Faculty")])
    assign(:booking_date, Date.current + 5.days)
    assign(:minimum_booking_date, Date.current + 5.days)
    assign(:time_slot_options, ["08:00", "08:30", "09:00"])
    assign(:timetable_slots, [])
    assign(:booking, Booking.new(
      venue: nil,
      user: nil
    ))
  end

  it "renders new booking form" do
    render

    assert_select "form.booking-date-filter[action=?][method=?]", new_booking_path, "get" do
      assert_select "input[name=?][min=?]", "booking_date", (Date.current + 5.days).to_s
    end

    assert_select "form[action=?][method=?]", confirm_bookings_path, "post" do
      assert_select "select[name=?]", "booking[venue_id]"
      assert_select "select[name=?]", "booking[start_slot]"
      assert_select "select[name=?]", "booking[end_slot]"
    end
  end
end
