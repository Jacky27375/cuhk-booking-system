FactoryBot.define do
  factory :tenant do
    name { "Computer Science Department" }
    sequence(:slug) { |n| "cs-dept-#{n}" }
    description { "A department at CUHK" }

    trait :two_step do
      approval_mode { :two_step }
    end
  end
end
