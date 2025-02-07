require 'rails_helper'

RSpec.describe Api::TaskDefinitionsController, type: :request do
  describe 'GET /api/task_definitions' do
    let!(:task_definitions) { create_list(:task_definition, 3) }

    it 'returns all task definitions' do
      get '/api/task_definitions', as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response.length).to eq(3)
    end
  end

  describe 'GET /api/task_definitions/:id' do
    let(:task_definition) { create(:task_definition) }

    it 'returns the requested task definition' do
      get "/api/task_definitions/#{task_definition.id}", as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(task_definition.id)
    end

    context 'with invalid id' do
      it 'returns not found status' do
        get '/api/task_definitions/0', as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'authenticated endpoints' do
    let(:agent) { create(:agent) }
    let(:headers) { authenticated_headers(agent) }

    describe 'POST /api/task_definitions' do
      let(:valid_params) do
        {
          task_definition: {
            name: 'Test Task',
            description: 'A test task',
            code: 'print("Hello, World!")',
            requirements: {
              min_memory: 1024,
              min_cpu_cores: 1,
              required_features: ['python3']
            }
          }
        }
      end

      context 'with valid parameters' do
        it 'creates a new task definition' do
          expect {
            post '/api/task_definitions', params: valid_params, headers: headers, as: :json
          }.to change(TaskDefinition, :count).by(1)
        end

        it 'returns created status' do
          post '/api/task_definitions', params: valid_params, headers: headers, as: :json
          expect(response).to have_http_status(:created)
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) do
          {
            task_definition: {
              name: '',
              description: '',
              code: '',
              requirements: nil
            }
          }
        end

        it 'returns unprocessable entity status' do
          post '/api/task_definitions', params: invalid_params, headers: headers, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns error messages' do
          post '/api/task_definitions', params: invalid_params, headers: headers, as: :json
          expect(json_response['errors']).to be_present
        end
      end
    end

    describe 'PUT /api/task_definitions/:id' do
      let(:task_definition) { create(:task_definition) }
      let(:update_params) do
        {
          task_definition: {
            name: 'Updated Task',
            description: 'An updated test task',
            requirements: {
              min_memory: 2048,
              min_cpu_cores: 2,
              required_features: ['python3', 'openai']
            }
          }
        }
      end

      it 'updates the task definition' do
        put "/api/task_definitions/#{task_definition.id}",
            params: update_params,
            headers: headers,
            as: :json

        task_definition.reload
        expect(task_definition.name).to eq('Updated Task')
        expect(task_definition.description).to eq('An updated test task')
        expect(task_definition.requirements['min_memory']).to eq(2048)
      end

      it 'returns success status' do
        put "/api/task_definitions/#{task_definition.id}",
            params: update_params,
            headers: headers,
            as: :json

        expect(response).to have_http_status(:ok)
      end

      context 'with invalid parameters' do
        let(:invalid_params) do
          {
            task_definition: {
              name: ''
            }
          }
        end

        it 'returns unprocessable entity status' do
          put "/api/task_definitions/#{task_definition.id}",
              params: invalid_params,
              headers: headers,
              as: :json

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe 'DELETE /api/task_definitions/:id' do
      let!(:task_definition) { create(:task_definition) }

      it 'deletes the task definition' do
        expect {
          delete "/api/task_definitions/#{task_definition.id}", headers: headers, as: :json
        }.to change(TaskDefinition, :count).by(-1)
      end

      it 'returns no content status' do
        delete "/api/task_definitions/#{task_definition.id}", headers: headers, as: :json
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end