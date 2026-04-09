FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@link.cuhk.edu.hk" }
    password { "Password1!" }
    password_confirmation { "Password1!" }
    role { :student }

    trait :admin do
      role { :admin }
    end

    trait :staff do
      role { :staff }
    end

    trait :student do
      role { :student }
    end

    trait :root_account do
      role { :staff }
      is_root_account { true }
      association :tenant
    end

    trait :with_tenant do
      association :tenant
    end

    trait :with_society do
      association :society
    end
  end
end
