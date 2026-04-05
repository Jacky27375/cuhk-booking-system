require 'rails_helper'

RSpec.describe BookingAccessPolicy do
  let(:science_tenant) { create(:tenant, name: 'Science Faculty') }
  let(:arts_tenant) { create(:tenant, name: 'Arts Faculty') }
  let(:science_staff) { create(:user, :staff, tenant: science_tenant) }
  let(:science_member) { create(:user, :society_member, tenant: science_tenant) }

  describe '.venue_accessible?' do
    it 'allows access to a venue in the same tenant' do
      venue = create(:venue, tenant: science_tenant, department: science_tenant.name)

      expect(described_class.venue_accessible?(science_staff, venue)).to be(true)
    end

    it 'denies access to a venue in another tenant' do
      venue = create(:venue, tenant: arts_tenant, department: arts_tenant.name)

      expect(described_class.venue_accessible?(science_member, venue)).to be(false)
    end
  end

  describe '.equipment_accessible?' do
    it 'allows access to equipment in the same tenant' do
      equipment = create(:equipment, tenant: science_tenant)

      expect(described_class.equipment_accessible?(science_member, equipment)).to be(true)
    end

    it 'denies access to equipment in another tenant' do
      equipment = create(:equipment, tenant: arts_tenant)

      expect(described_class.equipment_accessible?(science_staff, equipment)).to be(false)
    end
  end
end
