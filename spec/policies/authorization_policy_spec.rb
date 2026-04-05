require 'rails_helper'

RSpec.describe AuthorizationPolicy do
  describe '.admin_or_staff?' do
    it 'returns true for admin users' do
      user = create(:user, :admin)

      expect(described_class.admin_or_staff?(user)).to be(true)
    end

    it 'returns true for staff users' do
      user = create(:user, :staff)

      expect(described_class.admin_or_staff?(user)).to be(true)
    end

    it 'returns false for society members' do
      user = create(:user, :society_member)

      expect(described_class.admin_or_staff?(user)).to be(false)
    end
  end

  describe '.admin?' do
    it 'returns true only for admin users' do
      admin = create(:user, :admin)
      staff = create(:user, :staff)

      expect(described_class.admin?(admin)).to be(true)
      expect(described_class.admin?(staff)).to be(false)
    end
  end
end
