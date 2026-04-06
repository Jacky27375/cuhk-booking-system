require 'rails_helper'

RSpec.describe "equipments/index", type: :view do
  before(:each) do
    tenant = create(:tenant)
    admin = create(:user, :admin, tenant: tenant)

    def view.current_user=(user)
      @_current_user = user
    end

    def view.current_user
      @_current_user
    end

    view.current_user = admin

    equipment_1 = create(:equipment, name: "Projector", quantity: 3, tenant: tenant)
    equipment_2 = create(:equipment, name: "Microphone", quantity: 5, tenant: tenant)

    assign(:equipments, [equipment_1, equipment_2])
  end

  it "renders a grid-styled table of equipments" do
    render

    assert_select "table#equipments-table.resource-grid-table"
    assert_select "table#equipments-table tbody tr", count: 2
    expect(rendered).to include("Projector")
    expect(rendered).to include("Microphone")
  end
end
