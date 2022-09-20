FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Task#{n}"}
    content { "テストタスクです" }
    deadline { Time.current.since(7.days) }
    status { "doing" }
    user
  end
end
