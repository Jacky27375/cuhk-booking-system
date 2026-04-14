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
        start_time: 5.days.from_now.beginning_of_day + 10.hours,
        end_time: 5.days.from_now.beginning_of_day + 12.hours
      )
      expect(booking).to be_valid
    end

    it 'is invalid without a start_time' do
      booking = build(:booking, user: user, venue: venue, start_time: nil, end_time: 5.days.from_now.beginning_of_day + 12.hours)
      expect(booking).not_to be_valid
      expect(booking.errors[:start_time]).to include("can't be blank")
    end

    it 'is invalid without an end_time' do
      booking = build(:booking, user: user, venue: venue, start_time: 5.days.from_now.beginning_of_day + 10.hours, end_time: nil)
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

  describe 'status transitions' do
    it 'allows approval from under_review status' do
      booking = create(:booking, status: :under_review)

      booking.approve!

      expect(booking.reload.status).to eq('approved')
    end

    it 'blocks approval from rejected status' do
      booking = create(:booking, status: :rejected)

      expect { booking.approve! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(booking.reload.status).to eq('rejected')
    end

    it 'allows transition to under_review from pending status' do
      booking = create(:booking, status: :pending)

      booking.start_review!

      expect(booking.reload.status).to eq('under_review')
    end

    it 'allows rejection from under_review status' do
      booking = create(:booking, status: :under_review)

      booking.reject!('Capacity issue')

      expect(booking.reload.status).to eq('rejected')
      expect(booking.rejection_reason).to eq('Capacity issue')
    end

    it 'blocks rejection from approved status' do
      booking = create(:booking, status: :approved)

      expect { booking.reject!('Maintenance') }.to raise_error(ActiveRecord::RecordInvalid)
      expect(booking.reload.status).to eq('approved')
    end

    it 'allows cancellation from pending status' do
      booking = create(:booking, status: :pending)

      booking.cancel!

      expect(booking.reload.status).to eq('cancelled')
    end

    it 'blocks cancellation from returned status' do
      booking = create(:equipment_booking, status: :returned)

      expect { booking.cancel! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(booking.reload.status).to eq('returned')
    end

    it 'allows approved equipment bookings to be marked as returned' do
      booking = create(:equipment_booking, status: :approved)

      booking.mark_returned!

      expect(booking.reload.status).to eq('returned')
    end

    it 'does not allow venue bookings to be marked as returned' do
      booking = create(:booking, status: :approved)

      expect { booking.mark_returned! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(booking.reload.status).to eq('approved')
    end

    it 'does not allow pending equipment bookings to be marked as returned' do
      booking = create(:equipment_booking, status: :pending)

      expect { booking.mark_returned! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(booking.reload.status).to eq('pending')
    end

    it 'does not allow borrowed equipment bookings to be marked as returned' do
      booking = create(:equipment_booking, status: :borrowed)

      expect { booking.mark_returned! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(booking.reload.status).to eq('borrowed')
    end
  end

  describe '#cancelable_by_owner?' do
    it 'returns true for pending future venue bookings' do
      booking = build(:booking,
                      status: :pending,
                      start_time: 7.days.from_now.change(hour: 10, min: 0),
                      end_time: 7.days.from_now.change(hour: 12, min: 0))

      expect(booking.cancelable_by_owner?).to be(true)
    end

    it 'returns false for past venue bookings' do
      booking = build(:booking,
                      status: :pending,
                      start_time: 2.days.ago.change(hour: 10, min: 0),
                      end_time: 2.days.ago.change(hour: 12, min: 0))

      expect(booking.cancelable_by_owner?).to be(false)
    end
  end

  describe 'status broadcasts' do
    it 'broadcasts status payload when status changes' do
      booking = create(:booking, status: :pending)

      expect(ActionCable.server).to receive(:broadcast).with(
        "booking_status_user_#{booking.user_id}",
        hash_including(booking_id: booking.id, status: 'approved', status_label: 'Approved', rejection_reason: nil)
      )

      booking.update!(status: :approved)
    end

    it 'broadcasts rejection reason when status changes to rejected' do
      booking = create(:booking, status: :pending)

      expect(ActionCable.server).to receive(:broadcast).with(
        "booking_status_user_#{booking.user_id}",
        hash_including(
          booking_id: booking.id,
          status: 'rejected',
          status_label: 'Rejected',
          rejection_reason: 'Capacity issue'
        )
      )

      booking.reject!('Capacity issue')
    end

    it 'does not broadcast when status is unchanged' do
      booking = create(:booking, status: :pending)

      expect(ActionCable.server).not_to receive(:broadcast)

      booking.update!(end_time: booking.end_time + 1.hour)
    end
  end

  describe 'booking constraints' do
    describe 'VenueBooking constraints' do
      describe 'advance booking constraint (at least 5 days)' do
        it 'allows booking exactly 5 days in advance' do
          booking = build(
            :booking,
            user: user,
            venue: venue,
            start_time: 5.days.from_now.beginning_of_day + 10.hours,
            end_time: 5.days.from_now.beginning_of_day + 12.hours
          )
          expect(booking).to be_valid
        end

        it 'does not allow booking less than 5 days in advance' do
          booking = build(
            :booking,
            user: user,
            venue: venue,
            start_time: 4.days.from_now.beginning_of_day + 10.hours,
            end_time: 4.days.from_now.beginning_of_day + 12.hours
          )
          expect(booking).not_to be_valid
          expect(booking.errors[:base]).to include("Venue must be booked at least 5 days in advance")
        end

        it 'allows booking more than 5 days in advance' do
          booking = build(
            :booking,
            user: user,
            venue: venue,
            start_time: 10.days.from_now.beginning_of_day + 10.hours,
            end_time: 10.days.from_now.beginning_of_day + 12.hours
          )
          expect(booking).to be_valid
        end

        it 'does not allow booking today' do
          booking = build(
            :booking,
            user: user,
            venue: venue,
            start_time: Time.zone.now.beginning_of_day + 10.hours,
            end_time: Time.zone.now.beginning_of_day + 12.hours
          )
          expect(booking).not_to be_valid
          expect(booking.errors[:base]).to include("Venue must be booked at least 5 days in advance")
        end
      end

      describe 'duration constraint (max 4 hours)' do
        it 'allows booking exactly 4 hours' do
          booking = build(
            :booking,
            user: user,
            venue: venue,
            start_time: 5.days.from_now.beginning_of_day + 10.hours,
            end_time: 5.days.from_now.beginning_of_day + 14.hours
          )
          expect(booking).to be_valid
        end

        it 'does not allow booking more than 4 hours' do
          booking = build(
            :booking,
            user: user,
            venue: venue,
            start_time: 5.days.from_now.beginning_of_day + 10.hours,
            end_time: 5.days.from_now.beginning_of_day + 15.hours
          )
          expect(booking).not_to be_valid
          expect(booking.errors[:base]).to include("Booking duration cannot exceed 4 hours")
        end

        it 'allows booking less than 4 hours' do
          booking = build(
            :booking,
            user: user,
            venue: venue,
            start_time: 5.days.from_now.beginning_of_day + 10.hours,
            end_time: 5.days.from_now.beginning_of_day + 11.hours
          )
          expect(booking).to be_valid
        end
      end
    end

    describe 'EquipmentBooking constraints' do
      let(:equipment) { create(:equipment, tenant: tenant) }

      describe 'advance booking constraint (at least 5 days)' do
        it 'allows booking exactly 5 days in advance' do
          booking = build(
            :equipment_booking,
            user: user,
            equipment: equipment,
            quantity: 1,
            start_date: 5.days.from_now.to_date,
            end_date: 6.days.from_now.to_date
          )
          expect(booking).to be_valid
        end

        it 'does not allow booking less than 5 days in advance' do
          booking = build(
            :equipment_booking,
            user: user,
            equipment: equipment,
            quantity: 1,
            start_date: 4.days.from_now.to_date,
            end_date: 5.days.from_now.to_date
          )
          expect(booking).not_to be_valid
          expect(booking.errors[:base]).to include("Equipment must be booked at least 5 days in advance")
        end

        it 'allows booking more than 5 days in advance' do
          booking = build(
            :equipment_booking,
            user: user,
            equipment: equipment,
            quantity: 1,
            start_date: 10.days.from_now.to_date,
            end_date: 15.days.from_now.to_date
          )
          expect(booking).to be_valid
        end

        it 'does not allow booking today' do
          booking = build(
            :equipment_booking,
            user: user,
            equipment: equipment,
            quantity: 1,
            start_date: Date.current,
            end_date: 1.day.from_now.to_date
          )
          expect(booking).not_to be_valid
          expect(booking.errors[:base]).to include("Equipment must be booked at least 5 days in advance")
        end
      end

      describe 'duration constraint (max 7 days)' do
        it 'allows booking exactly 7 days' do
          booking = build(
            :equipment_booking,
            user: user,
            equipment: equipment,
            quantity: 1,
            start_date: 5.days.from_now.to_date,
            end_date: 12.days.from_now.to_date
          )
          expect(booking).to be_valid
        end

        it 'does not allow booking more than 7 days' do
          booking = build(
            :equipment_booking,
            user: user,
            equipment: equipment,
            quantity: 1,
            start_date: 5.days.from_now.to_date,
            end_date: 13.days.from_now.to_date
          )
          expect(booking).not_to be_valid
          expect(booking.errors[:base]).to include("Equipment booking duration cannot exceed 7 days")
        end

        it 'allows booking less than 7 days' do
          booking = build(
            :equipment_booking,
            user: user,
            equipment: equipment,
            quantity: 1,
            start_date: 5.days.from_now.to_date,
            end_date: 10.days.from_now.to_date
          )
          expect(booking).to be_valid
        end
      end
    end
  end
end
