require 'rails_helper'

RSpec.describe BookingConflictChecker do
  let(:tenant) { create(:tenant, name: 'Science Faculty') }
  let(:user) { create(:user, :society_member, tenant: tenant) }
  let(:venue) { create(:venue, tenant: tenant, department: tenant.name) }

  it 'detects an overlapping booking' do
    create(
      :booking,
      user: user,
      venue: venue,
      start_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 10:00:00'),
      end_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 12:00:00')
    )

    booking = build(
      :booking,
      user: user,
      venue: venue,
      start_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 11:00:00'),
      end_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 13:00:00')
    )

    expect(described_class.new(booking).conflict_exists?).to be(true)
  end

  it 'ignores non-overlapping bookings' do
    create(
      :booking,
      user: user,
      venue: venue,
      start_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 10:00:00'),
      end_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 12:00:00')
    )

    booking = build(
      :booking,
      user: user,
      venue: venue,
      start_time: Time.zone.parse('2026-04-10 12:00:00'),
      end_time: Time.zone.parse('2026-04-10 14:00:00')
    )

    expect(described_class.new(booking).conflict_exists?).to be(false)
  end

  it 'ignores cancelled overlapping bookings' do
    create(
      :booking,
      user: user,
      venue: venue,
      status: :cancelled,
      start_time: Time.zone.parse('2026-04-10 10:00:00'),
      end_time: Time.zone.parse('2026-04-10 12:00:00')
    )

    booking = build(
      :booking,
      user: user,
      venue: venue,
      start_time: Time.zone.parse('2026-04-10 11:00:00'),
      end_time: Time.zone.parse('2026-04-10 13:00:00')
    )

    expect(described_class.new(booking).conflict_exists?).to be(false)
  end
end
