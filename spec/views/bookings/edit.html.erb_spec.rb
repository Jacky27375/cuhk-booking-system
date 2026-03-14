require 'rails_helper'

RSpec.describe "bookings/edit", type: :view do
  let(:booking) { FactoryBot.create(:booking) }

  before(:each) do
    assign(:booking, booking)
  end

  it "renders the edit booking form" do
    render

    assert_select "form[action=?][method=?]", booking_path(booking), "post" do
      assert_select "input[name=?]", "booking[venue_id]"
    end
  end
end
