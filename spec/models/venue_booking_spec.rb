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
      start_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 10:00:00'),
      end_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 12:00:00')
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

  it 'rejects expired pending venue bookings' do
    future_date = 6.days.from_now.to_date
    expired_booking = create(
      :booking,
      user: user,
      venue: venue,
      start_time: Time.zone.local(future_date.year, future_date.month, future_date.day, 10, 0, 0),
      end_time: Time.zone.local(future_date.year, future_date.month, future_date.day, 12, 0, 0),
      status: :pending
    )

    expired_date = 1.day.ago.to_date
    expired_booking.update_columns(
      start_time: Time.zone.local(expired_date.year, expired_date.month, expired_date.day, 10, 0, 0),
      end_time: Time.zone.local(expired_date.year, expired_date.month, expired_date.day, 12, 0, 0),
      status: Booking.statuses[:pending],
      rejection_reason: nil,
      updated_at: Time.current
    )

    described_class.reject_expired_pending!(at: Time.current)

    expect(expired_booking.reload.status).to eq('rejected')
    expect(expired_booking.rejection_reason).to eq('Booking date has passed')
  end

  it 'rejects a third venue booking for the same student on the same day' do
    booking_date = 5.days.from_now.to_date
    time_at = ->(hour) { Time.zone.local(booking_date.year, booking_date.month, booking_date.day, hour, 0, 0) }

    create(
      :booking,
      user: user,
      venue: venue,
      start_time: time_at.call(9),
      end_time: time_at.call(10)
    )
    create(
      :booking,
      user: user,
      venue: create(:venue, tenant: tenant, department: tenant.name),
      start_time: time_at.call(11),
      end_time: time_at.call(12)
    )

    booking = build(
      :booking,
      user: user,
      venue: create(:venue, tenant: tenant, department: tenant.name),
      start_time: time_at.call(13),
      end_time: time_at.call(14)
    )

    expect(booking).not_to be_valid
    expect(booking.errors[:base]).to include('You can book at most 2 venues per day')
  end
end
