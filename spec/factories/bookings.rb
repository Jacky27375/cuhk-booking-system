FactoryBot.define do
  factory :booking do
    association :user
    venue { association(:venue, tenant: user&.tenant) }
    start_time { 1.day.from_now }
    end_time { 1.day.from_now + 2.hours }
    status { :pending }
  end
end
