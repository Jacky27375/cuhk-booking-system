require 'rails_helper'

RSpec.describe "bookings/show", type: :view do
  before(:each) do
    @booking = assign(:booking, FactoryBot.create(:booking))
  end

  it "renders resource and user attributes" do
    render
    expect(rendered).to match(/Resource:/)
    expect(rendered).to match(/User:/)
  end
end
