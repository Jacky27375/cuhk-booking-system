require 'rails_helper'

RSpec.describe "venues/index", type: :view do
  before(:each) do
    def view.current_user; nil; end
    assign(:venues, [
      Venue.create!(
        name: "Venue 1",
        description: "Desc 1",
        department: "Science Faculty"
      ),
      Venue.create!(
        name: "Venue 2",
        description: "Desc 2",
        department: "Science Faculty"
      )
    ])
  end

  it "renders a list of venues" do
    render
    assert_select "table#venues-table.resource-grid-table"
    assert_select "table#venues-table tbody tr", count: 2
    expect(rendered).to include("Venue 1")
    expect(rendered).to include("Venue 2")
    expect(rendered).to include("Desc 1")
    expect(rendered).to include("Desc 2")
  end
end
