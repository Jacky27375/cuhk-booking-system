require 'rails_helper'

RSpec.describe "bookings/index", type: :view do
  before(:each) do
    @booking1 = FactoryBot.create(:booking)
    @booking2 = FactoryBot.create(:booking)
    assign(:bookings, [@booking1, @booking2])
  end

  it "renders a list of bookings" do
    render
    assert_select "div>strong", text: "Venue:", count: 2
    assert_select "div>strong", text: "User:", count: 2
  end
end
