FactoryBot.define do
  factory :comment do
    sequence(:comment) { |n| "コメント#{n}"}
    task
    user
  end
end
