require 'rails_helper'

RSpec.describe Tenant, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:tenant)).to be_valid
    end

    it 'requires a name' do
      tenant = build(:tenant, name: nil)
      expect(tenant).not_to be_valid
      expect(tenant.errors[:name]).to include("can't be blank")
    end

    it 'requires a slug' do
      tenant = build(:tenant, slug: nil)
      expect(tenant).not_to be_valid
      expect(tenant.errors[:slug]).to include("can't be blank")
    end

    it 'requires a unique slug' do
      create(:tenant, slug: 'cs-dept-unique')
      tenant = build(:tenant, slug: 'cs-dept-unique')
      expect(tenant).not_to be_valid
      expect(tenant.errors[:slug]).to include("has already been taken")
    end
  end

  describe 'associations' do
    it 'has many users' do
      assoc = Tenant.reflect_on_association(:users)
      expect(assoc).not_to be_nil
      expect(assoc.macro).to eq(:has_many)
    end

    it 'can have many users' do
      tenant = create(:tenant)
      create_list(:user, 2, :staff, tenant: tenant)
      expect(tenant.users.count).to eq(2)
    end
  end
end
