require 'rails_helper'

RSpec.describe Api::AgentsController, type: :request do
  describe 'POST /api/agents/register' do
    let(:valid_params) do
      {
        agent: {
          name: 'test-agent',
          capabilities: {
            memory: 8192,
            cpu_cores: 4,
            features: ['python3', 'openai']
          }
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new agent' do
        expect {
          post '/api/agents/register', params: valid_params, as: :json
        }.to change(Agent, :count).by(1)
      end

      it 'returns a JWT token' do
        post '/api/agents/register', params: valid_params, as: :json
        expect(response).to have_http_status(:created)
        expect(json_response['token']).to be_present
      end

      it 'sets the initial status to online' do
        post '/api/agents/register', params: valid_params, as: :json
        expect(json_response['agent']['status']).to eq('online')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { agent: { name: '' } } }

      it 'returns unprocessable entity status' do
        post '/api/agents/register', params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        post '/api/agents/register', params: invalid_params, as: :json
        expect(json_response['errors']).to be_present
      end
    end
  end

  describe 'authenticated endpoints' do
    let(:agent) { create(:agent) }
    let(:headers) { authenticated_headers(agent) }

    describe 'POST /api/agents/heartbeat' do
      it 'updates last_seen_at timestamp' do
        expect {
          post '/api/agents/heartbeat', headers: headers
        }.to change { agent.reload.last_seen_at }
      end

      it 'returns success response' do
        post '/api/agents/heartbeat', headers: headers
        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('ok')
      end
    end

    describe 'PUT /api/agents/status' do
      it 'updates agent status' do
        put '/api/agents/status', params: { status: 'busy' }, headers: headers, as: :json
        expect(agent.reload.status).to eq('busy')
      end

      it 'returns success response' do
        put '/api/agents/status', params: { status: 'busy' }, headers: headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('ok')
      end

      context 'with invalid status' do
        it 'returns unprocessable entity status' do
          put '/api/agents/status', params: { status: 'invalid' }, headers: headers, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe 'PUT /api/agents/capabilities' do
      let(:new_capabilities) do
        {
          memory: 16384,
          cpu_cores: 8,
          features: ['python3', 'openai', 'ffmpeg']
        }
      end

      it 'updates agent capabilities' do
        put '/api/agents/capabilities', params: { capabilities: new_capabilities }, headers: headers, as: :json
        expect(agent.reload.capabilities).to eq(new_capabilities.stringify_keys)
      end

      it 'returns success response' do
        put '/api/agents/capabilities', params: { capabilities: new_capabilities }, headers: headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('ok')
      end
    end
  end

  describe 'authentication' do
    let(:agent) { create(:agent) }

    it 'returns unauthorized for invalid token' do
      post '/api/agents/heartbeat', headers: { 'Authorization' => 'Bearer invalid' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized for missing token' do
      post '/api/agents/heartbeat'
      expect(response).to have_http_status(:unauthorized)
    end
  end
end