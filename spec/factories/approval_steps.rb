FactoryBot.define do
  factory :approval_step do
    association :booking
    association :actor, factory: :user
    action { "approve" }
    from_status { "pending" }
    to_status { "approved" }
    reason { nil }
  end
end
