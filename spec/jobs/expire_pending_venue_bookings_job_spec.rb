require 'rails_helper'

RSpec.describe ExpirePendingVenueBookingsJob, type: :job do
  let(:tenant) { create(:tenant, name: 'University', slug: 'university') }
  let(:user) { create(:user, tenant: tenant) }
  let(:venue) { create(:venue, tenant: tenant, department: tenant.name) }

  it 'rejects pending venue bookings whose booking date has passed' do
    expired_booking = create(
      :booking,
      user: user,
      venue: venue,
      start_time: Time.zone.parse("#{5.days.from_now.to_date} 10:00:00"),
      end_time: Time.zone.parse("#{5.days.from_now.to_date} 12:00:00"),
      status: :pending
    )
    expired_booking.update_columns(
      start_time: Time.zone.parse("#{1.day.ago.to_date} 10:00:00"),
      end_time: Time.zone.parse("#{1.day.ago.to_date} 12:00:00"),
      status: Booking.statuses[:pending],
      rejection_reason: nil,
      updated_at: Time.current
    )
    future_booking = create(
      :booking,
      user: user,
      venue: venue,
      start_time: Time.zone.parse("#{5.days.from_now.to_date} 10:00:00"),
      end_time: Time.zone.parse("#{5.days.from_now.to_date} 12:00:00"),
      status: :pending
    )

    described_class.perform_now

    expect(expired_booking.reload.status).to eq('rejected')
    expect(expired_booking.rejection_reason).to eq('Booking date has passed')
    expect(future_booking.reload.status).to eq('pending')
  end
end
