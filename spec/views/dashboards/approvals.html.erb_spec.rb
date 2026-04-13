require 'rails_helper'

RSpec.describe "dashboards/approvals", type: :view do
  before(:each) do
    tenant = create(:tenant, name: "Science Faculty")
    venue = create(:venue, name: "Room 101", department: tenant.name, tenant: tenant)
    user = create(:user, :student, tenant: tenant)

    booking_1 = create(:booking,
               venue: venue,
               user: user,
               status: :pending,
               start_time: 5.days.from_now.change(hour: 10, min: 0),
               end_time: 5.days.from_now.change(hour: 12, min: 0))
    booking_2 = create(:booking,
               venue: venue,
               user: user,
               status: :pending,
               start_time: 5.days.from_now.change(hour: 13, min: 0),
               end_time: 5.days.from_now.change(hour: 15, min: 0))

    assign(:bookings, [booking_1, booking_2])
    assign(:pending_venue_requests, [])
    assign(:sort_column, nil)
    assign(:sort_direction, nil)
  end

  it "renders a grid-styled approvals table" do
    render

    assert_select "table#approvals-table.resource-grid-table"
    assert_select "table#approvals-table tbody tr", count: 2
    assert_select "table#approvals-table td.approval-actions-cell", count: 2
    assert_select "table#approvals-table .approval-action-stack", count: 2
    expect(rendered).to include("Room 101")
    expect(rendered).to include("Pending")
  end

  it "renders pending staff venue requests when present" do
    request = create(:venue_request, venue_name: "Lab 401")
    assign(:pending_venue_requests, [request])

    render

    expect(rendered).to include("Pending Staff Venue Requests")
    expect(rendered).to include("Lab 401")
    expect(rendered).to include(request.requester.email)
  end
end
