FactoryBot.define do
  factory :comment do
    sequence(:comment) { |n| "コメント#{n}"}
    association :task
    association :user
  end
end
