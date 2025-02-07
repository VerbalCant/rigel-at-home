require 'rails_helper'

RSpec.describe TaskDefinition, type: :model do
  describe 'associations' do
    it { should have_many(:tasks).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:task_definition) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:requirements) }
  end

  describe '#create_task!' do
    let(:task_definition) { create(:task_definition) }

    context 'without an agent' do
      it 'creates a pending task' do
        task = task_definition.create_task!
        expect(task).to be_persisted
        expect(task.status).to eq('pending')
        expect(task.agent).to be_nil
      end
    end

    context 'with an agent' do
      let(:agent) { create(:agent) }

      it 'creates an assigned task' do
        task = task_definition.create_task!(agent)
        expect(task).to be_persisted
        expect(task.status).to eq('assigned')
        expect(task.agent).to eq(agent)
      end
    end

    it 'copies attributes from task definition' do
      task = task_definition.create_task!
      expect(task.name).to eq(task_definition.name)
      expect(task.description).to eq(task_definition.description)
      expect(task.code).to eq(task_definition.code)
    end
  end

  describe '#compatible_with_agent?' do
    let(:task_definition) { create(:task_definition, :high_requirements) }

    context 'with a capable agent' do
      let(:agent) { create(:agent) }

      it 'returns true' do
        expect(task_definition).to be_compatible_with_agent(agent)
      end
    end

    context 'with an agent having minimal capabilities' do
      let(:agent) { create(:agent, :minimal_capabilities) }

      it 'returns false' do
        expect(task_definition).not_to be_compatible_with_agent(agent)
      end
    end

    context 'with invalid capabilities data' do
      let(:agent) { create(:agent, capabilities: 'invalid') }

      it 'returns false' do
        expect(task_definition).not_to be_compatible_with_agent(agent)
      end
    end

    context 'with specific requirements' do
      let(:task_definition) { create(:task_definition, :with_openai) }

      it 'returns true for agents with required features' do
        agent = create(:agent, capabilities: {
          memory: 2048,
          cpu_cores: 2,
          features: ['python3', 'openai']
        })
        expect(task_definition).to be_compatible_with_agent(agent)
      end

      it 'returns false for agents missing required features' do
        agent = create(:agent, capabilities: {
          memory: 2048,
          cpu_cores: 2,
          features: ['python3']
        })
        expect(task_definition).not_to be_compatible_with_agent(agent)
      end
    end
  end
end