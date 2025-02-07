require 'rails_helper'

RSpec.describe TaskAssignmentService do
  describe '#assign_next_task' do
    let(:agent) { create(:agent) }
    let(:service) { described_class.new(agent) }

    context 'when agent is not available' do
      before { agent.update(status: 'busy') }

      it 'returns nil' do
        expect(service.assign_next_task).to be_nil
      end
    end

    context 'when no tasks are pending' do
      it 'returns nil' do
        expect(service.assign_next_task).to be_nil
      end
    end

    context 'when pending tasks exist' do
      let!(:task) { create(:task) }

      it 'assigns the task to the agent' do
        assigned_task = service.assign_next_task
        expect(assigned_task).to eq(task)
        expect(assigned_task.agent).to eq(agent)
        expect(assigned_task.status).to eq('assigned')
      end

      it 'marks the agent as busy' do
        service.assign_next_task
        expect(agent.reload.status).to eq('busy')
      end
    end

    context 'when multiple pending tasks exist' do
      let!(:incompatible_task) { create(:task, task_definition: create(:task_definition, :high_requirements)) }
      let!(:compatible_task) { create(:task) }
      let(:agent) { create(:agent, :minimal_capabilities) }

      it 'assigns the first compatible task' do
        assigned_task = service.assign_next_task
        expect(assigned_task).to eq(compatible_task)
      end
    end

    context 'when an error occurs during assignment' do
      before do
        allow_any_instance_of(Task).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
      end

      let!(:task) { create(:task) }

      it 'returns nil and logs the error' do
        expect { service.assign_next_task }.to output(/ALAINA: Error assigning task:/).to_stdout
        expect(service.assign_next_task).to be_nil
      end
    end
  end

  describe '.cleanup_stale_tasks' do
    let!(:recent_task) { create(:task, :running) }
    let!(:stale_task) { create(:task, :stale) }

    it 'marks stale tasks as failed' do
      described_class.cleanup_stale_tasks
      expect(stale_task.reload.status).to eq('failed')
      expect(stale_task.result['error']).to eq('Task timed out')
    end

    it 'does not affect recent tasks' do
      described_class.cleanup_stale_tasks
      expect(recent_task.reload.status).to eq('running')
    end

    it 'marks agents of stale tasks as online' do
      agent = stale_task.agent
      described_class.cleanup_stale_tasks
      expect(agent.reload.status).to eq('online')
    end

    it 'logs cleanup activities' do
      expect {
        described_class.cleanup_stale_tasks
      }.to output(
        /ALAINA: Starting stale task cleanup.*Found stale task.*Successfully cleaned up stale task.*Completed stale task cleanup/m
      ).to_stdout
    end
  end
end