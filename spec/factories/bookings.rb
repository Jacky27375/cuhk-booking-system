FactoryBot.define do
  factory :booking do
    association :venue
    association :user
    start_time { 1.day.from_now }
    end_time { 1.day.from_now + 2.hours }
  end
end
