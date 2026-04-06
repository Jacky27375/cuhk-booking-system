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

    it "can exclude the current booking when recalculating availability" do
      eq = Equipment.create!(name: "Projector", quantity: 1, tenant: tenant)
      user = create(:user, tenant: tenant)
      booking = create(:equipment_booking, user: user, equipment: eq, quantity: 1, status: :approved)

      expect(eq.available_quantity).to eq(0)
      expect(eq.available_quantity(excluding_booking_id: booking.id)).to eq(1)
    end
  end

  describe '.visible_to_student' do
    let!(:uni_tenant) { Tenant.create!(name: 'University', slug: 'university') }
    let!(:shaw_tenant) { Tenant.create!(name: 'Shaw College', slug: 'shaw') }
    let!(:na_tenant) { Tenant.create!(name: 'New Asia College', slug: 'new-asia') }

    let!(:uni_equipment) { Equipment.create!(name: 'Uni Projector', quantity: 2, tenant: uni_tenant) }
    let!(:shaw_equipment) { Equipment.create!(name: 'Shaw Camera', quantity: 2, tenant: shaw_tenant) }
    let!(:na_equipment) { Equipment.create!(name: 'NA Mic', quantity: 2, tenant: na_tenant) }

    let(:shaw_student) { User.create!(email: "stu.#{Time.now.to_i}@link.cuhk.edu.hk", password: 'Password1!', password_confirmation: 'Password1!', role: :society_member, tenant: shaw_tenant) }

    it 'returns equipment for the users college and university shared equipment only' do
      equipments = Equipment.visible_to_student(shaw_student)
      expect(equipments).to include(shaw_equipment)
      expect(equipments).to include(uni_equipment)
      expect(equipments).not_to include(na_equipment)
    end
  end
end
