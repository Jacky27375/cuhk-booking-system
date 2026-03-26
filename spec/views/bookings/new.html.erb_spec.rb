require 'rails_helper'

RSpec.describe "bookings/new", type: :view do
  before(:each) do
    assign(:venues, [create(:venue, name: "Room 101", department: "Science Faculty")])
    assign(:booking, Booking.new(
      venue: nil,
      user: nil
    ))
  end

  it "renders new booking form" do
    render

    assert_select "form[action=?][method=?]", bookings_path, "post" do
      assert_select "select[name=?]", "booking[venue_id]"
    end
  end
end
