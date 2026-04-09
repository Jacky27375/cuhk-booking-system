require 'rails_helper'

RSpec.describe Venue, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      venue = build(:venue)
      expect(venue).to be_valid
    end

    it 'is invalid without a name' do
      venue = build(:venue, name: nil)
      expect(venue).not_to be_valid
      expect(venue.errors[:name]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'has many bookings' do
      association = Venue.reflect_on_association(:bookings)
      expect(association.macro).to eq(:has_many)
    end

    it 'destroys dependent bookings' do
      tenant = create(:tenant, name: 'University', slug: 'university')
      venue = create(:venue, tenant: tenant, department: tenant.name)
      user = create(:user, tenant: tenant)
      create(:booking, venue: venue, user: user, start_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 10:00:00'), end_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 12:00:00'))
      expect { venue.destroy }.to change { Booking.count }.by(-1)
    end
  end

  describe '.visible_to_student' do
    let!(:uni_tenant) { create(:tenant, name: 'University', slug: 'university') }
    let!(:shaw_tenant) { create(:tenant, name: 'Shaw College', slug: 'shaw') }
    let!(:na_tenant) { create(:tenant, name: 'New Asia College', slug: 'new-asia') }

    let!(:uni_venue) { create(:venue, name: 'Music Room G04', tenant: uni_tenant) }
    let!(:shaw_venue) { create(:venue, name: 'Lecture Theatre', tenant: shaw_tenant) }
    let!(:na_venue) { create(:venue, name: 'Yali Lounge', tenant: na_tenant) }

    let(:shaw_student) { create(:user, role: :student, tenant: shaw_tenant) }

    it 'returns venues for the users college and university shared venues only' do
      venues = Venue.visible_to_student(shaw_student)
      expect(venues).to include(shaw_venue)
      expect(venues).to include(uni_venue)
      expect(venues).not_to include(na_venue)
    end
  end
end
