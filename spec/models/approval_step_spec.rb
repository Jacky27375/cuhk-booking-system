require "rails_helper"

RSpec.describe ApprovalStep, type: :model do
  describe "validations" do
    it "is valid with supported action and statuses" do
      expect(build(:approval_step)).to be_valid
    end

    it "is invalid with unsupported action" do
      step = build(:approval_step, action: "archive")

      expect(step).not_to be_valid
      expect(step.errors[:action]).to include("is not included in the list")
    end

    it "is invalid with unsupported statuses" do
      step = build(:approval_step, from_status: "unknown", to_status: "unknown")

      expect(step).not_to be_valid
      expect(step.errors[:from_status]).to include("is not included in the list")
      expect(step.errors[:to_status]).to include("is not included in the list")
    end
  end

  describe "associations" do
    it "belongs to booking" do
      expect(described_class.reflect_on_association(:booking).macro).to eq(:belongs_to)
    end

    it "belongs to actor" do
      association = described_class.reflect_on_association(:actor)
      expect(association.macro).to eq(:belongs_to)
      expect(association.class_name).to eq("User")
    end
  end
end
