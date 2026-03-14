require 'rails_helper'

RSpec.describe "bookings/show", type: :view do
  before(:each) do
    @booking = assign(:booking, FactoryBot.create(:booking))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Venue:/)
    expect(rendered).to match(/User:/)
  end
end
