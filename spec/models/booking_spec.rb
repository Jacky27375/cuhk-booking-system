require 'rails_helper'

RSpec.describe Booking, type: :model do
  let(:tenant) { create(:tenant, name: "University", slug: "university") }
  let(:user) { create(:user, tenant: tenant) }
  let(:venue) { create(:venue, tenant: tenant, department: tenant.name) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      booking = build(
        :booking,
        user: user,
        venue: venue,
        start_time: Time.zone.parse("2026-04-10 10:00:00"),
        end_time: Time.zone.parse("2026-04-10 12:00:00")
      )
      expect(booking).to be_valid
    end

    it 'is invalid without a start_time' do
      booking = build(:booking, user: user, venue: venue, start_time: nil, end_time: Time.zone.parse("2026-04-10 12:00:00"))
      expect(booking).not_to be_valid
      expect(booking.errors[:start_time]).to include("can't be blank")
    end

    it 'is invalid without an end_time' do
      booking = build(:booking, user: user, venue: venue, start_time: Time.zone.parse("2026-04-10 10:00:00"), end_time: nil)
      expect(booking).not_to be_valid
      expect(booking.errors[:end_time]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'belongs to a venue' do
      association = Booking.reflect_on_association(:venue)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to a user' do
      association = Booking.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe 'booking subclasses' do
    it 'builds venue bookings by default from the booking factory' do
      booking = build(:booking, user: user, venue: venue)

      expect(booking).to be_a(VenueBooking)
    end

    it 'renders booking partials consistently for STI subclasses' do
      booking = build(:booking, user: user, venue: venue)

      expect(booking.to_partial_path).to eq('bookings/booking')
    end
  end

  describe '.for_tenant' do
    let(:science_tenant) { create(:tenant, name: 'Science Faculty') }
    let(:arts_tenant) { create(:tenant, name: 'Arts Faculty') }
    let(:science_user) { create(:user, tenant: science_tenant) }
    let(:arts_user) { create(:user, tenant: arts_tenant) }

    it 'includes bookings on venues linked to the same tenant' do
      scoped_venue = create(:venue, department: science_tenant.name, tenant: science_tenant)
      other_venue = create(:venue, department: arts_tenant.name, tenant: arts_tenant)
      included_booking = create(:booking, venue: scoped_venue, user: science_user)
      create(:booking, venue: other_venue, user: arts_user)

      expect(Booking.for_tenant(science_tenant)).to contain_exactly(included_booking)
    end

    it 'supports legacy venues without tenant_id using department name fallback' do
      legacy_venue = create(:venue, department: science_tenant.name, tenant: nil)
      booking = create(:booking, venue: legacy_venue, user: science_user)

      expect(Booking.for_tenant(science_tenant)).to include(booking)
    end
  end

  describe 'status broadcasts' do
    it 'broadcasts status payload when status changes' do
      booking = create(:booking, status: :pending)

      expect(ActionCable.server).to receive(:broadcast).with(
        "booking_status_user_#{booking.user_id}",
        hash_including(booking_id: booking.id, status: 'approved', status_label: 'Approved')
      )

      booking.update!(status: :approved)
    end

    it 'does not broadcast when status is unchanged' do
      booking = create(:booking, status: :pending)

      expect(ActionCable.server).not_to receive(:broadcast)

      booking.update!(end_time: booking.end_time + 1.hour)
    end
  end
end
