FactoryBot.define do
  factory :task_definition do
    sequence(:name) { |n| "Task Definition #{n}" }
    description { Faker::Lorem.paragraph }
    code { "import time\nprint('Hello, World!')\ntime.sleep(1)" }
    requirements do
      {
        min_memory: 1024,
        min_cpu_cores: 1,
        required_features: ['python3']
      }
    end

    trait :high_requirements do
      requirements do
        {
          min_memory: 8192,
          min_cpu_cores: 4,
          required_features: ['python3', 'openai', 'ffmpeg']
        }
      end
    end

    trait :with_openai do
      code do
        <<~PYTHON
          import openai
          response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": "Hello!"}]
          )
          print(response.choices[0].message.content)
        PYTHON
      end
      requirements do
        {
          min_memory: 2048,
          min_cpu_cores: 2,
          required_features: ['python3', 'openai']
        }
      end
    end
  end
end