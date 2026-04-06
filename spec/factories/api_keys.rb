FactoryBot.define do
  factory :api_key do
    association :user
    sequence(:name) { |n| "API Key #{n}" }
    active { true }
    expires_at { nil }
  end
end
