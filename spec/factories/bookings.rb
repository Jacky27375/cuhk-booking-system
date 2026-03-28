FactoryBot.define do
  factory :booking do
    association :user, :with_tenant
    venue { association(:venue, tenant: user.tenant, department: user.tenant.name) }
    start_time { Time.zone.tomorrow.change(hour: 10, min: 0) }
    end_time { Time.zone.tomorrow.change(hour: 12, min: 0) }
    status { :pending }
  end
end
