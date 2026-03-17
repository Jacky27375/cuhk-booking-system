FactoryBot.define do
  factory :booking do
    user { nil }
    equipment { nil }
    quantity { 1 }
    start_date { "2026-03-15" }
    end_date { "2026-03-15" }
    status { "MyString" }
  end
end
