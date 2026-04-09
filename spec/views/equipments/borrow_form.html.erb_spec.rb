require 'rails_helper'

RSpec.describe 'equipments/borrow_form', type: :view do
  before(:each) do
    tenant = create(:tenant, name: 'Science Faculty')
    equipment = create(:equipment, tenant: tenant, name: 'Projector', quantity: 3)
    assign(:equipment, equipment)
    assign(:booking, EquipmentBooking.new(equipment: equipment))
  end

  it 'renders borrow form with minimum dates' do
    render

    expected_min = 5.days.from_now.to_date.to_s

    assert_select 'form' do
      assert_select 'input[name=?][min=?]', 'booking[start_date]', expected_min
      assert_select 'input[name=?][min=?]', 'booking[end_date]', expected_min
    end
  end
end
