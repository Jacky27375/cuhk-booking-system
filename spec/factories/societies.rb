FactoryBot.define do
  factory :society do
    sequence(:name) { |n| "Computer Science Society #{n}" }
    description { "A student society at CUHK" }
  end
end
