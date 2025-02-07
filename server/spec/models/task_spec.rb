require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'associations' do
    it { should belong_to(:agent).optional }
    it { should belong_to(:task_definition) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_inclusion_of(:status).in_array(%w[pending assigned running completed failed]) }
  end

  describe 'callbacks' do
    it 'sets initial status to pending' do
      task = build(:task, status: nil)
      task.valid?
      expect(task.status).to eq('pending')
    end
  end

  describe 'scopes' do
    let!(:pending_task) { create(:task) }
    let!(:running_task) { create(:task, :running) }
    let!(:completed_task) { create(:task, :completed) }
    let!(:failed_task) { create(:task, :failed) }

    it '.pending returns only pending tasks' do
      expect(Task.pending).to contain_exactly(pending_task)
    end

    it '.running returns only running tasks' do
      expect(Task.running).to contain_exactly(running_task)
    end

    it '.completed returns only completed tasks' do
      expect(Task.completed).to contain_exactly(completed_task)
    end

    it '.failed returns only failed tasks' do
      expect(Task.failed).to contain_exactly(failed_task)
    end
  end

  describe 'instance methods' do
    let(:task) { create(:task, :assigned) }

    describe '#start!' do
      it 'updates status to running and sets started_at' do
        expect {
          task.start!
        }.to change { task.status }.to('running')
        .and change { task.started_at }.from(nil)
      end
    end

    describe '#complete!' do
      let(:result_data) { { 'output' => 'Success', 'execution_time' => 1.5 } }

      it 'updates status to completed and sets result data' do
        expect {
          task.complete!(result_data)
        }.to change { task.status }.to('completed')
        .and change { task.completed_at }.from(nil)
        .and change { task.result }.to(result_data)
      end
    end

    describe '#fail!' do
      let(:error_message) { 'Task execution failed' }

      it 'updates status to failed and sets error message' do
        expect {
          task.fail!(error_message)
        }.to change { task.status }.to('failed')
        .and change { task.completed_at }.from(nil)
        .and change { task.result }.to({ 'error' => error_message })
      end
    end
  end
end