require 'rails_helper'

RSpec.describe BookingScopeQuery do
  let(:science_tenant) { create(:tenant, name: 'Science Faculty') }
  let(:arts_tenant) { create(:tenant, name: 'Arts Faculty') }

  it 'includes venue bookings for the matching tenant' do
    science_venue = create(:venue, tenant: science_tenant, department: science_tenant.name)
    arts_venue = create(:venue, tenant: arts_tenant, department: arts_tenant.name)
    science_booking = create(:booking, venue: science_venue, user: create(:user, :society_member, tenant: science_tenant))
    create(:booking, venue: arts_venue, user: create(:user, :society_member, tenant: arts_tenant))

    expect(described_class.for_tenant(science_tenant)).to contain_exactly(science_booking)
  end

  it 'includes equipment bookings for the matching tenant' do
    equipment = create(:equipment, tenant: science_tenant)
    booking = create(
      :equipment_booking,
      equipment: equipment,
      user: create(:user, :society_member, tenant: science_tenant),
      quantity: 1,
      start_date: Date.current,
      end_date: Date.current + 1.day,
      status: :borrowed
    )

    expect(described_class.for_tenant(science_tenant)).to include(booking)
  end
end
