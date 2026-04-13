require 'rails_helper'

RSpec.describe 'equipments/borrow_form', type: :view do
  before(:each) do
    tenant = create(:tenant, name: 'Science Faculty')
    equipment = create(:equipment, tenant: tenant, name: 'Projector', quantity: 3)
    assign(:equipment, equipment)
    assign(:booking, EquipmentBooking.new(equipment: equipment))
  end

  it 'renders borrow form with date constraints' do
    render

    expected_min = 5.days.from_now.to_date.to_s

    assert_select "form[data-controller='booking-date-range']" do
      assert_select "input[name='booking[start_date]'][min='#{expected_min}'][data-booking-date-range-target='startDate'][data-action*='booking-date-range#syncEndDateMinimum']"
      assert_select "input[name='booking[end_date]'][min='#{expected_min}'][data-booking-date-range-target='endDate']"
    end
  end
end
