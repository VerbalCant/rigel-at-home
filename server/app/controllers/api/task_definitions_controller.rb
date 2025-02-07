module Api
  class TaskDefinitionsController < BaseController
    skip_before_action :authenticate_request, only: [:index, :show]
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::ParameterMissing do |e|
      puts "ALAINA: Parameter missing: #{e.message}"
      render json: { error: e.message }, status: :bad_request
    end

    def index
      task_definitions = TaskDefinition.all
      render json: task_definitions
    end

    def show
      task_definition = TaskDefinition.find(params[:id])
      render json: task_definition
    end

    def create
      puts "ALAINA: Creating task definition with params: #{params.inspect}"
      task_definition = TaskDefinition.new(task_definition_params)

      if task_definition.save
        puts "ALAINA: New task definition created: #{task_definition.name}"
        render json: task_definition, status: :created
      else
        puts "ALAINA: Failed to create task definition: #{task_definition.errors.full_messages}"
        render json: { errors: task_definition.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      puts "ALAINA: Updating task definition with params: #{params.inspect}"
      task_definition = TaskDefinition.find(params[:id])

      if task_definition.update(task_definition_params)
        puts "ALAINA: Task definition updated: #{task_definition.name}"
        render json: task_definition
      else
        puts "ALAINA: Failed to update task definition: #{task_definition.errors.full_messages}"
        render json: { errors: task_definition.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      task_definition = TaskDefinition.find(params[:id])
      task_definition.destroy

      puts "ALAINA: Task definition deleted: #{task_definition.name}"
      head :no_content
    end

    private

    def task_definition_params
      if params[:task_definition].present?
        params.require(:task_definition).permit(:name, :description, :code, requirements: {})
      else
        params.permit(:name, :description, :code, requirements: {})
      end
    end

    def not_found
      render json: { error: 'Task definition not found' }, status: :not_found
    end
  end
end