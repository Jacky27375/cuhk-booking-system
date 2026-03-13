FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@cuhk.edu.hk" }
    password { "Password1!" }
    role { :society_member }

    trait :admin do
      role { :admin }
    end

    trait :staff do
      role { :staff }
    end

    trait :society_member do
      role { :society_member }
    end

    trait :with_tenant do
      association :tenant
    end

    trait :with_society do
      association :society
    end
  end
end
