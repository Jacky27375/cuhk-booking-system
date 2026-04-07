require 'rails_helper'

RSpec.describe "bookings/index", type: :view do
  before(:each) do
    def view.current_user
      nil
    end

    @booking1 = FactoryBot.create(:booking)
    @booking2 = FactoryBot.create(:booking)
    assign(:bookings, [@booking1, @booking2])
  end

  it "renders a list of bookings" do
    render
    assert_select "table#bookings-venue-table.resource-grid-table"
    assert_select "table#bookings-venue-table tbody tr", count: 2
    expect(rendered).to include(@booking1.venue.name)
    expect(rendered).to include(@booking2.venue.name)
    expect(rendered).to include(@booking1.user.email)
    expect(rendered).to include(@booking2.user.email)
  end
end
