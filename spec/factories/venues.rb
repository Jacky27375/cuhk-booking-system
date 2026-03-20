FactoryBot.define do
  factory :venue do
    sequence(:name) { |n| "Venue #{n}" }
    description { "MyText" }
    department { "Science Faculty" }
  end
end
