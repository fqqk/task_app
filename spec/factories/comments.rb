FactoryBot.define do
  factory :comment do
    sequence(:comment) { |n| "コメント#{n}"}
    association :task
    user_id { task.user_id }
  end
end
