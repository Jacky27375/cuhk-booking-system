require 'rails_helper'

RSpec.describe User, type: :model do
  include ActiveSupport::Testing::TimeHelpers

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
      create(:user, email: 'test@link.cuhk.edu.hk')
      user = build(:user, email: 'TEST@link.cuhk.edu.hk')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it 'requires a valid email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("must be a valid @link.cuhk.edu.hk address")
    end

    it 'requires a password on create' do
      user = build(:user, password: nil, password_confirmation: nil)
      expect(user).not_to be_valid
    end

    it 'requires a password of at least 10 characters' do
      user = build(:user, password: 'Short1!', password_confirmation: 'Short1!')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 10 characters)")
    end

    it 'requires password complexity with uppercase, lowercase, number, and symbol' do
      user = build(:user, password: 'Password12', password_confirmation: 'Password12')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include(
        "must include at least one uppercase letter, one lowercase letter, one number, and one symbol"
      )
    end

    it 'normalizes email to lowercase' do
      user = create(:user, email: ' MixedCaseUser@link.CUHK.edu.hk ')
      expect(user.email).to eq('mixedcaseuser@link.cuhk.edu.hk')
    end
  end

  describe '.generate_compliant_password' do
    it 'returns a password that satisfies complexity requirements' do
      password = described_class.generate_compliant_password(length: 12)

      expect(password.length).to be >= 12
      expect(password).to match(User::PASSWORD_COMPLEXITY_REGEX)
    end
  end

  describe 'roles' do
    it 'defines admin role' do
      expect(build(:user, :admin)).to be_admin
    end

    it 'defines staff role' do
      expect(build(:user, :staff)).to be_staff
    end

    it 'defines student role' do
      expect(build(:user, :student)).to be_student
    end

    it 'defaults to student' do
      expect(User.new).to be_student
    end

    it 'can list all roles' do
      expect(User.roles.keys).to contain_exactly('student', 'staff', 'admin')
    end
  end

  describe 'associations' do
    it 'optionally belongs to a tenant' do
      assoc = User.reflect_on_association(:tenant)
      expect(assoc).not_to be_nil
      expect(assoc.macro).to eq(:belongs_to)
    end

    it 'is valid without a tenant' do
      expect(build(:user, tenant: nil)).to be_valid
    end

    it 'can belong to a tenant' do
      tenant = create(:tenant)
      user = create(:user, :staff, tenant: tenant)
      expect(user.tenant).to eq(tenant)
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

  describe '#deletable_by_admin?' do
    let(:acting_admin) { create(:user, :admin) }

    it 'returns false for root staff accounts' do
      root_staff = create(:user, :root_account, tenant: create(:tenant))

      expect(root_staff.deletable_by_admin?(acting_admin)).to be(false)
    end

    it 'returns true for regular staff accounts' do
      staff = create(:user, :staff, tenant: create(:tenant))

      expect(staff.deletable_by_admin?(acting_admin)).to be(true)
    end
  end

  describe 'active session lock' do
    let(:user) { create(:user, :admin) }

    it 'stores an issued timestamp when creating a session token' do
      travel_to(Time.zone.parse('2026-04-13 12:00:00 UTC')) do
        user.issue_active_session_token!

        expect(user.reload.active_session_token).to be_present
        expect(user.active_session_token_issued_at).to eq(Time.current)
      end
    end

    it 'treats legacy lock records without timestamp as expired' do
      user.update!(active_session_token: SecureRandom.hex(32), active_session_token_issued_at: nil)

      expect(user.active_session_lock_expired?).to be(true)
    end

    it 'clears lock columns when the lock has expired' do
      user.update!(
        active_session_token: SecureRandom.hex(32),
        active_session_token_issued_at: 13.hours.ago
      )

      expect(user.clear_expired_active_session_lock!).to be(true)
      user.reload

      expect(user.active_session_token).to be_nil
      expect(user.active_session_token_issued_at).to be_nil
    end
  end
end
