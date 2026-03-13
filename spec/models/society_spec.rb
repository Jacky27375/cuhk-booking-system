require 'rails_helper'

RSpec.describe Society, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:society)).to be_valid
    end

    it 'requires a name' do
      society = build(:society, name: nil)
      expect(society).not_to be_valid
      expect(society.errors[:name]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'has many users' do
      assoc = Society.reflect_on_association(:users)
      expect(assoc).not_to be_nil
      expect(assoc.macro).to eq(:has_many)
    end

    it 'can have many users' do
      society = create(:society)
      create_list(:user, 2, society: society)
      expect(society.users.count).to eq(2)
    end
  end
end
