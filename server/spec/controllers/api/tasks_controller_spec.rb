require 'rails_helper'

RSpec.describe Api::TasksController, type: :request do
  let(:agent) { create(:agent) }
  let(:headers) { authenticated_headers(agent) }

  describe 'GET /api/tasks' do
    let!(:agent_task) { create(:task, agent: agent) }
    let!(:other_task) { create(:task) }

    it 'returns only tasks belonging to the agent' do
      get '/api/tasks', headers: headers, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response.length).to eq(1)
      expect(json_response.first['id']).to eq(agent_task.id)
    end
  end

  describe 'POST /api/tasks/request' do
    context 'when agent is available' do
      context 'with compatible pending tasks' do
        let!(:task) { create(:task) }

        it 'assigns a task to the agent' do
          post '/api/tasks/request', headers: headers, as: :json
          expect(response).to have_http_status(:ok)
          expect(json_response['id']).to eq(task.id)
        end

        it 'includes task details in response' do
          post '/api/tasks/request', headers: headers, as: :json
          expect(json_response).to include(
            'name' => task.name,
            'code' => task.code,
            'description' => task.description
          )
        end
      end

      context 'without compatible pending tasks' do
        it 'returns no tasks available message' do
          post '/api/tasks/request', headers: headers, as: :json
          expect(response).to have_http_status(:ok)
          expect(json_response['message']).to eq('No tasks available')
        end
      end
    end

    context 'when agent is busy' do
      before { agent.update(status: 'busy') }

      it 'returns no tasks available message' do
        post '/api/tasks/request', headers: headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('No tasks available')
      end
    end
  end

  describe 'PUT /api/tasks/:id/progress' do
    let(:task) { create(:task, :running, agent: agent) }

    it 'updates task progress' do
      put "/api/tasks/#{task.id}/progress",
          params: { status: 'running', progress_data: { percent: 50 } },
          headers: headers,
          as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('ok')
    end

    context 'with invalid task id' do
      it 'returns not found status' do
        put '/api/tasks/0/progress',
            params: { status: 'running' },
            headers: headers,
            as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT /api/tasks/:id/complete' do
    let(:task) { create(:task, :running, agent: agent) }
    let(:result_data) { { output: 'Success', execution_time: 1.5 } }

    it 'marks task as completed' do
      put "/api/tasks/#{task.id}/complete",
          params: { result: result_data },
          headers: headers,
          as: :json

      expect(response).to have_http_status(:ok)
      expect(task.reload.status).to eq('completed')
      expect(task.result).to eq(result_data.stringify_keys)
    end

    it 'marks agent as online' do
      put "/api/tasks/#{task.id}/complete",
          params: { result: result_data },
          headers: headers,
          as: :json

      expect(agent.reload.status).to eq('online')
    end
  end

  describe 'PUT /api/tasks/:id/fail' do
    let(:task) { create(:task, :running, agent: agent) }
    let(:error_message) { 'Task execution failed' }

    it 'marks task as failed' do
      put "/api/tasks/#{task.id}/fail",
          params: { error_message: error_message },
          headers: headers,
          as: :json

      expect(response).to have_http_status(:ok)
      expect(task.reload.status).to eq('failed')
      expect(task.result['error']).to eq(error_message)
    end

    it 'marks agent as online' do
      put "/api/tasks/#{task.id}/fail",
          params: { error_message: error_message },
          headers: headers,
          as: :json

      expect(agent.reload.status).to eq('online')
    end
  end
end