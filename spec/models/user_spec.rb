require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { User.new(email: 'test@link.cuhk.edu.hk', password: 'password1', role: 'student') }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is invalid without an email' do
      subject.email = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("can't be blank")
    end

    it 'is invalid with a duplicate email' do
      User.create!(email: 'test@link.cuhk.edu.hk', password: 'password1', role: 'student')
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include('has already been taken')
    end

    it 'is invalid with a badly formatted email' do
      subject.email = 'not-an-email'
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include('is invalid')
    end

    it 'is invalid without a role' do
      subject.role = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:role]).to include("can't be blank")
    end

    it 'is invalid with an unrecognised role' do
      subject.role = 'superuser'
      expect(subject).not_to be_valid
      expect(subject.errors[:role]).to include('is not included in the list')
    end

    it 'is invalid without a password on create' do
      user = User.new(email: 'new@link.cuhk.edu.hk', role: 'student', password: '')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end
  end

  describe 'roles' do
    it 'accepts student role' do
      user = User.new(email: 'a@link.cuhk.edu.hk', password: 'password1', role: 'student')
      expect(user).to be_valid
    end

    it 'accepts staff role' do
      user = User.new(email: 'b@link.cuhk.edu.hk', password: 'password1', role: 'staff')
      expect(user).to be_valid
    end

    it 'accepts admin role' do
      user = User.new(email: 'c@link.cuhk.edu.hk', password: 'password1', role: 'admin')
      expect(user).to be_valid
    end

    it 'provides role query methods' do
      student = User.new(role: 'student')
      staff   = User.new(role: 'staff')
      admin   = User.new(role: 'admin')

      expect(student.student?).to be true
      expect(student.staff?).to be false
      expect(staff.staff?).to be true
      expect(admin.admin?).to be true
    end
  end

  describe 'has_secure_password' do
    it 'authenticates with correct password' do
      user = User.create!(email: 'auth@link.cuhk.edu.hk', password: 'password1', role: 'student')
      expect(user.authenticate('password1')).to eq(user)
    end

    it 'does not authenticate with wrong password' do
      user = User.create!(email: 'auth@link.cuhk.edu.hk', password: 'password1', role: 'student')
      expect(user.authenticate('wrong')).to be_falsey
    end
  end

  describe '.find_by_email_case_insensitive' do
    it 'finds users regardless of email case' do
      User.create!(email: 'Student@LINK.CUHK.edu.hk', password: 'password1', role: 'student')
      expect(User.find_by_email_case_insensitive('student@link.cuhk.edu.hk')).to be_present
    end
  end
end
