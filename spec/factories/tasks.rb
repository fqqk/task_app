FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Task#{n}"}
    content { "テストタスクです" }
    deadline { 1.week.from.now }
    status { "doing" }
    association :owner
  end
end
