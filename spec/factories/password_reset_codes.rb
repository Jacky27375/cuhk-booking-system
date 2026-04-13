FactoryBot.define do
  factory :password_reset_code do
    sequence(:email) { |n| "reset#{n}@link.cuhk.edu.hk" }
    code_digest { BCrypt::Password.create("123456") }
    expires_at { 10.minutes.from_now }
    used_at { nil }
    attempt_count { 0 }
    resend_count { 0 }
    last_sent_at { Time.current }
  end
end
