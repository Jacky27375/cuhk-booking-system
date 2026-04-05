require 'rails_helper'

RSpec.describe VenueBooking, type: :model do
  let(:tenant) { create(:tenant, name: 'University', slug: 'university') }
  let(:user) { create(:user, tenant: tenant) }
  let(:venue) { create(:venue, tenant: tenant, department: tenant.name) }

  it 'validates venue booking rules' do
    booking = build(
      :booking,
      user: user,
      venue: venue,
      start_time: Time.zone.parse('2026-04-10 10:00:00'),
      end_time: Time.zone.parse('2026-04-10 12:00:00')
    )

    expect(booking).to be_valid
  end

  it 'rejects a venue booking outside the allowed window' do
    booking = build(
      :booking,
      user: user,
      venue: venue,
      start_time: Time.zone.parse('2026-04-10 07:00:00'),
      end_time: Time.zone.parse('2026-04-10 08:00:00')
    )

    expect(booking).not_to be_valid
    expect(booking.errors[:base]).to include('must be between 08:00 and 22:00')
  end
end