FactoryBot.define do
  factory :user, aliases: [:owner] do
    name  { "福士斗真" }
    sequence(:email) { |n| "test#{n}@example.com"}
    password { "testpass0608" }
    password_confirmation { "testpass0608" }
    created_at {Time.now}
    updated_at {Time.now}
  end
end
