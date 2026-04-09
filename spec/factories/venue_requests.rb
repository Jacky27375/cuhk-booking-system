FactoryBot.define do
  factory :venue_request do
    sequence(:venue_name) { |n| "Room #{n}" }
    description { "A new venue for events" }
    status { :pending }
    association :requester, factory: [:user, :staff]
    association :tenant
  end
end
