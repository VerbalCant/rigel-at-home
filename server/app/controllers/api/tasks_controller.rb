module Api
  class TasksController < BaseController
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::ParameterMissing do |e|
      Rails.logger.info("ALAINA: Parameter missing: #{e.message}")
      render json: { error: e.message }, status: :bad_request
    end

    def index
      tasks = current_agent.tasks
      render json: tasks
    end

    def request_task
      service = TaskAssignmentService.new(current_agent)
      task = service.assign_next_task

      if task
        render json: task
      else
        render json: { message: 'No tasks available' }
      end
    end

    def update_progress
      Rails.logger.info("ALAINA: Updating task progress with params: #{params.inspect}")
      task = current_agent.tasks.find(params[:id])

      if task.update(progress_params)
        Rails.logger.info("ALAINA: Task #{task.id} progress updated: #{task.progress_data}")
        render json: { status: 'ok', task: task }
      else
        Rails.logger.info("ALAINA: Failed to update task progress: #{task.errors.full_messages}")
        render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.info("ALAINA: Task not found: #{e.message}")
      render json: { error: 'Task not found' }, status: :not_found
    end

    def complete
      Rails.logger.info("ALAINA: Completing task with params: #{params.inspect}")
      task = current_agent.tasks.find(params[:id])

      begin
        ActiveRecord::Base.transaction do
          task.complete!(complete_params)
          current_agent.mark_as_online!
        end
        Rails.logger.info("ALAINA: Task #{task.id} completed with result: #{task.result}")
        render json: task
      rescue StandardError => e
        Rails.logger.info("ALAINA: Failed to complete task: #{e.message}")
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.info("ALAINA: Task not found: #{e.message}")
      render json: { error: 'Task not found' }, status: :not_found
    end

    def fail
      Rails.logger.info("ALAINA: Failing task with params: #{params.inspect}")
      task = current_agent.tasks.find(params[:id])
      error_message = params[:error] || params[:error_message] || 'Task failed'

      begin
        ActiveRecord::Base.transaction do
          task.fail!(error_message)
          current_agent.mark_as_online!
        end
        Rails.logger.info("ALAINA: Task #{task.id} failed with error: #{error_message}")
        render json: task
      rescue StandardError => e
        Rails.logger.info("ALAINA: Failed to mark task as failed: #{e.message}")
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.info("ALAINA: Task not found: #{e.message}")
      render json: { error: 'Task not found' }, status: :not_found
    end

    private

    def progress_params
      params.permit(:status).tap do |whitelisted|
        whitelisted[:progress_data] = params[:progress_data].to_unsafe_h if params[:progress_data].present?
      end
    end

    def complete_params
      if params[:result].present?
        params[:result].to_unsafe_h
      elsif params[:result_data].present?
        params[:result_data].to_unsafe_h
      else
        {}
      end
    end

    def not_found
      render json: { error: 'Task not found' }, status: :not_found
    end
  end
end