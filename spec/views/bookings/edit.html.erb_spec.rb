require 'rails_helper'

RSpec.describe "bookings/edit", type: :view do
  let(:tenant) { create(:tenant, name: "University", slug: "university") }
  let(:user) { create(:user, tenant: tenant) }
  let(:venue) { create(:venue, name: "Room 101", department: "University", tenant: tenant) }
  let(:booking) do
    create(
      :booking,
      user: user,
      venue: venue,
      start_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 10:00:00'),
      end_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 11:00:00')
    )
  end

  before(:each) do
    assign(:booking_date, booking.start_time.to_date)
    assign(:minimum_booking_date, Date.current + 5.days)
    assign(:time_slot_options, ["08:00", "08:30", "09:00"])
    assign(:timetable_slots, [])
    assign(:booking, booking)
  end

  it "renders the edit booking form" do
    render

    assert_select "form[action=?][method=?]", booking_path(booking), "post" do
      assert_select "input[name=?]", "booking[venue_id]"
      assert_select "select[name=?]", "booking[start_slot]"
      assert_select "select[name=?]", "booking[end_slot]"
    end
  end
end
