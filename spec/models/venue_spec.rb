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
      venue = create(:venue)
      create(:booking, venue: venue)
      
      expect { venue.destroy }.to change { Booking.count }.by(-1)
    end
  end
end

