require 'rails_helper'

RSpec.describe "venues/index", type: :view do
  before(:each) do
    def view.current_user; nil; end
    assign(:venues, [
      Venue.create!(
        name: "Venue 1",
        description: "Desc 1"
      ),
      Venue.create!(
        name: "Venue 2",
        description: "Desc 2"
      )
    ])
  end

  it "renders a list of venues" do
    render
    assert_select "div>strong", text: "Name:", count: 2
    assert_select "div>strong", text: "Description:", count: 2
    assert_select "div", text: /Venue 1/
    assert_select "div", text: /Venue 2/
    assert_select "div", text: /Desc 1/
    assert_select "div", text: /Desc 2/
  end
end
