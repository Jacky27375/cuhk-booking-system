require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:user, :admin)).to be_valid
    end

    it 'requires an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'requires a unique email (case-insensitive)' do
      create(:user, email: 'test@cuhk.edu.hk')
      user = build(:user, email: 'TEST@cuhk.edu.hk')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it 'requires a valid email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("is invalid")
    end

    it 'requires a password on create' do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end

    it 'requires a password of at least 8 characters' do
      user = build(:user, password: 'short')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
    end

    it 'normalizes email to lowercase' do
      user = create(:user, email: ' Admin@CUHK.edu.hk ')
      expect(user.email).to eq('admin@cuhk.edu.hk')
    end
  end

  describe 'roles' do
    it 'defines admin role' do
      expect(build(:user, :admin)).to be_admin
    end

    it 'defines staff role' do
      expect(build(:user, :staff)).to be_staff
    end

    it 'defines society_member role' do
      expect(build(:user, :society_member)).to be_society_member
    end

    it 'defaults to society_member' do
      expect(User.new).to be_society_member
    end

    it 'can list all roles' do
      expect(User.roles.keys).to contain_exactly('society_member', 'staff', 'admin')
    end
  end

  describe 'associations' do
    it 'optionally belongs to a tenant' do
      assoc = User.reflect_on_association(:tenant)
      expect(assoc).not_to be_nil
      expect(assoc.macro).to eq(:belongs_to)
    end

    it 'optionally belongs to a society' do
      assoc = User.reflect_on_association(:society)
      expect(assoc).not_to be_nil
      expect(assoc.macro).to eq(:belongs_to)
    end

    it 'is valid without a tenant' do
      expect(build(:user, tenant: nil)).to be_valid
    end

    it 'is valid without a society' do
      expect(build(:user, society: nil)).to be_valid
    end

    it 'can belong to a tenant' do
      tenant = create(:tenant)
      user = create(:user, :staff, tenant: tenant)
      expect(user.tenant).to eq(tenant)
    end

    it 'can belong to a society' do
      society = create(:society)
      user = create(:user, :society_member, society: society)
      expect(user.society).to eq(society)
    end
  end

  describe 'authentication' do
    let(:user) { create(:user, :admin) }

    it 'authenticates with correct password' do
      expect(user.authenticate('Password1!')).to eq(user)
    end

    it 'rejects incorrect password' do
      expect(user.authenticate('wrongpassword')).to be_falsey
    end
  end
end
