FactoryBot.define do
  factory :booking do
    user { nil }
    equipment { nil }
    quantity { 1 }
    start_date { "2026-03-15" }
    end_date { "2026-03-15" }
    status { "MyString" }
    association :venue
    association :user
    start_time { 1.day.from_now }
    end_time { 1.day.from_now + 2.hours }
    status { :pending }
  end
end
