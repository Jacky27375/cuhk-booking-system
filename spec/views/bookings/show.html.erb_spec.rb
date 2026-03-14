require 'rails_helper'

RSpec.describe "bookings/show", type: :view do
  before(:each) do
    assign(:booking, Booking.create!(
      venue: nil,
      user: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
