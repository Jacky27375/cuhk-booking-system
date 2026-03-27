FactoryBot.define do
  factory :venue do
    sequence(:name) { |n| "Venue #{n}" }
    description { "MyText" }
    department { "Science Faculty" }

    trait :with_tenant do
      association :tenant, name: department
    end
  end
end
