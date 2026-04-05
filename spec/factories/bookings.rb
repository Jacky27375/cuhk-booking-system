FactoryBot.define do
  factory :booking, class: "VenueBooking" do
    association :user, :with_tenant
    venue { association(:venue, tenant: user.tenant, department: user.tenant.name) }
    start_time { 1.day.from_now.change(hour: 10, min: 0) }
    end_time { 1.day.from_now.change(hour: 12, min: 0) }
    status { :pending }
  end

  factory :equipment_booking, class: "EquipmentBooking" do
    association :user, :with_tenant
    equipment { association(:equipment, tenant: user.tenant) }
    quantity { 1 }
    start_date { 1.day.from_now.to_date }
    end_date { 2.days.from_now.to_date }
    status { :pending }
  end
end
