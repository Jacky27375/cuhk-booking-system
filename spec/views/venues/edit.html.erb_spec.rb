require 'rails_helper'

RSpec.describe "venues/edit", type: :view do
  let(:venue) {
    Venue.create!(
      name: "MyString",
      description: "MyText",
      department: "Science Faculty"
    )
  }

  before(:each) do
    assign(:venue, venue)
    assign(:departments, ["New Asia College"])
  end

  it "renders the edit venue form" do
    render

    assert_select "form[action=?][method=?]", venue_path(venue), "post" do
      assert_select "input[name=?]", "venue[name]"

      assert_select "textarea[name=?]", "venue[description]"
      assert_select "select[name=?] option", "venue[department]", count: 1
    end
  end
end
