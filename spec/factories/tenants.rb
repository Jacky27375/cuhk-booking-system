FactoryBot.define do
  factory :tenant do
    name { "Computer Science Department" }
    sequence(:slug) { |n| "cs-dept-#{n}" }
    description { "A department at CUHK" }
  end
end
