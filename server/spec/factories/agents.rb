FactoryBot.define do
  factory :agent do
    name { Faker::Internet.unique.username }
    status { 'online' }
    last_seen_at { Time.current }
    capabilities do
      {
        memory: 8192,
        cpu_cores: 4,
        features: ['python3', 'openai', 'ffmpeg']
      }
    end

    trait :offline do
      status { 'offline' }
    end

    trait :busy do
      status { 'busy' }
    end

    trait :minimal_capabilities do
      capabilities do
        {
          memory: 1024,
          cpu_cores: 1,
          features: ['python3']
        }
      end
    end
  end
end