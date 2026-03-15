require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      booking = build(:booking)
      expect(booking).to be_valid
    end

    it 'is invalid without a start_time' do
      booking = build(:booking, start_time: nil)
      expect(booking).not_to be_valid
      expect(booking.errors[:start_time]).to include("can't be blank")
    end

    it 'is invalid without an end_time' do
      booking = build(:booking, end_time: nil)
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
end
