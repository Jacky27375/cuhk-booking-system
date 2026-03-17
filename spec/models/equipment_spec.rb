require 'rails_helper'

RSpec.describe Equipment, type: :model do
  let(:tenant) { Tenant.create!(name: "Science", slug: "sci") }

  describe "validations" do
    it "is valid with a name and quantity" do
      eq = Equipment.new(name: "Projector", quantity: 5, tenant: tenant)
      expect(eq).to be_valid
    end

    it "is invalid without a name" do
      eq = Equipment.new(quantity: 5, tenant: tenant)
      expect(eq).not_to be_valid
    end

    it "cannot have negative quantity" do
      eq = Equipment.new(name: "Laptop", quantity: -1, tenant: tenant)
      expect(eq).not_to be_valid
    end
  end

  describe "#available_quantity" do
    it "calculates remaining units correctly" do
      eq = Equipment.create!(name: "iPad", quantity: 10, tenant: tenant)
      expect(eq.available_quantity).to eq(10)
    end
  end
end
