require 'rails_helper'

RSpec.describe "venues/new", type: :view do
  before(:each) do
    assign(:venue, Venue.new(
      name: "MyString",
      description: "MyText"
    ))
    assign(:departments, ["New Asia College"])
  end

  it "renders new venue form" do
    render

    assert_select "form[action=?][method=?]", venues_path, "post" do
      assert_select "input[name=?]", "venue[name]"

      assert_select "textarea[name=?]", "venue[description]"
      assert_select "select[name=?] option", "venue[department]", count: 1
    end
  end
end
