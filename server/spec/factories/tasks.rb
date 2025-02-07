FactoryBot.define do
  factory :task do
    association :task_definition
    name { task_definition.name }
    description { task_definition.description }
    code { task_definition.code }
    status { 'pending' }

    trait :assigned do
      association :agent
      status { 'assigned' }
    end

    trait :running do
      association :agent
      status { 'running' }
    end

    trait :completed do
      association :agent
      status { 'completed' }
      result { { output: "Hello, World!\n", execution_time: 1.23 } }
    end

    trait :failed do
      association :agent
      status { 'failed' }
      result { { error: 'Task execution failed', details: 'Python runtime error' } }
    end

    trait :stale do
      association :agent
      status { 'running' }
      updated_at { 2.hours.ago }
    end
  end
end