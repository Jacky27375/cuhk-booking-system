FactoryBot.define do
  factory :equipment do
    name { "MyString" }
    quantity { 1 }
    association :tenant
  end
end
