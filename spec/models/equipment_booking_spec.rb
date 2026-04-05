require 'rails_helper'

RSpec.describe EquipmentBooking, type: :model do
  let(:tenant) { create(:tenant, name: 'University', slug: 'university') }
  let(:user) { create(:user, tenant: tenant) }
  let(:equipment) { create(:equipment, tenant: tenant, quantity: 3) }

  it 'validates equipment booking rules' do
    booking = build(
      :equipment_booking,
      user: user,
      equipment: equipment,
      quantity: 1,
      start_date: Date.parse('2026-04-10'),
      end_date: Date.parse('2026-04-12')
    )

    expect(booking).to be_valid
  end

  it 'rejects quantities above availability' do
    booking = build(
      :equipment_booking,
      user: user,
      equipment: equipment,
      quantity: 5,
      start_date: Date.parse('2026-04-10'),
      end_date: Date.parse('2026-04-12')
    )

    expect(booking).not_to be_valid
    expect(booking.errors[:base]).to include('Not enough units available')
  end
end
