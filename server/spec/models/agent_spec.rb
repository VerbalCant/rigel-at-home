require 'rails_helper'

RSpec.describe Agent, type: :model do
  describe 'associations' do
    it { should have_many(:tasks).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:capabilities) }
    it { should validate_inclusion_of(:status).in_array(%w[online offline busy]) }
  end

  describe 'instance methods' do
    let(:agent) { create(:agent) }

    describe '#available?' do
      it 'returns true when status is online' do
        expect(agent).to be_available
      end

      it 'returns false when status is offline' do
        agent.update(status: 'offline')
        expect(agent).not_to be_available
      end

      it 'returns false when status is busy' do
        agent.update(status: 'busy')
        expect(agent).not_to be_available
      end
    end

    describe '#update_last_seen!' do
      it 'updates the last_seen_at timestamp' do
        expect {
          travel 1.hour do
            agent.update_last_seen!
          end
        }.to change { agent.last_seen_at }
      end
    end

    describe 'status update methods' do
      it '#mark_as_offline! sets status to offline' do
        agent.mark_as_offline!
        expect(agent.reload.status).to eq('offline')
      end

      it '#mark_as_online! sets status to online' do
        agent.mark_as_online!
        expect(agent.reload.status).to eq('online')
      end

      it '#mark_as_busy! sets status to busy' do
        agent.mark_as_busy!
        expect(agent.reload.status).to eq('busy')
      end
    end
  end
end