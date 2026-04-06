require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  let(:user) { create(:user) }

  describe "validations" do
    it "is valid with valid attributes" do
      api_key = build(:api_key, user: user)
      expect(api_key).to be_valid
    end

    it "requires a name" do
      api_key = build(:api_key, user: user, name: nil)
      expect(api_key).not_to be_valid
      expect(api_key.errors[:name]).to include("can't be blank")
    end

    it "requires a user" do
      api_key = build(:api_key, user: nil)
      expect(api_key).not_to be_valid
    end

    it "generates a token automatically on create" do
      api_key = create(:api_key, user: user)
      expect(api_key.token).to be_present
      expect(api_key.token.length).to eq(64)
    end

    it "enforces unique tokens" do
      existing = create(:api_key, user: user)
      duplicate = build(:api_key, user: user, token: existing.token)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:token]).to include("has already been taken")
    end
  end

  describe "#usable?" do
    it "returns true for an active, non-expired key" do
      api_key = create(:api_key, user: user, active: true, expires_at: nil)
      expect(api_key.usable?).to be true
    end

    it "returns false for an inactive key" do
      api_key = create(:api_key, user: user, active: false)
      expect(api_key.usable?).to be false
    end

    it "returns false for an expired key" do
      api_key = create(:api_key, user: user, expires_at: 1.day.ago)
      expect(api_key.usable?).to be false
    end

    it "returns true for a key with future expiry" do
      api_key = create(:api_key, user: user, expires_at: 1.day.from_now)
      expect(api_key.usable?).to be true
    end
  end

  describe ".active scope" do
    it "excludes inactive keys" do
      create(:api_key, user: user, active: false)
      active_key = create(:api_key, user: user, active: true)
      expect(ApiKey.active).to eq([active_key])
    end

    it "excludes expired keys" do
      create(:api_key, user: user, expires_at: 1.day.ago)
      valid_key = create(:api_key, user: user, expires_at: 1.day.from_now)
      expect(ApiKey.active).to eq([valid_key])
    end
  end

  describe "#touch_last_used!" do
    it "updates last_used_at" do
      api_key = create(:api_key, user: user)
      expect(api_key.last_used_at).to be_nil
      api_key.touch_last_used!
      expect(api_key.reload.last_used_at).to be_within(2.seconds).of(Time.current)
    end
  end
end
