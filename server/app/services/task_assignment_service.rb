class TaskAssignmentService
  def initialize(agent)
    @agent = agent
  end

  def assign_next_task
    return nil unless @agent.available?

    puts "ALAINA: Looking for tasks compatible with agent #{@agent.name}"

    # Find all pending tasks
    pending_tasks = Task.pending.includes(:task_definition)

    # Find the first compatible task
    compatible_task = pending_tasks.find do |task|
      task.task_definition.compatible_with_agent?(@agent)
    end

    return nil unless compatible_task

    puts "ALAINA: Found compatible task #{compatible_task.id} for agent #{@agent.name}"

    begin
      ActiveRecord::Base.transaction do
        compatible_task.update!(agent: @agent, status: 'assigned')
        @agent.mark_as_busy!
        puts "ALAINA: Successfully assigned task #{compatible_task.id} to agent #{@agent.name}"
      end
      compatible_task
    rescue StandardError => e
      puts "ALAINA: Error assigning task: #{e.message}"
      nil
    end
  end

  def self.cleanup_stale_tasks
    puts "ALAINA: Starting stale task cleanup"

    # Find tasks that have been running for too long (e.g., > 1 hour)
    stale_tasks = Task.running.where('updated_at < ?', 1.hour.ago)

    stale_tasks.each do |task|
      puts "ALAINA: Found stale task #{task.id}"

      begin
        ActiveRecord::Base.transaction do
          task.fail!('Task timed out')
          task.agent&.mark_as_online!
        end
        puts "ALAINA: Successfully cleaned up stale task #{task.id}"
      rescue StandardError => e
        puts "ALAINA: Error cleaning up stale task #{task.id}: #{e.message}"
      end
    end

    puts "ALAINA: Completed stale task cleanup"
  end
end