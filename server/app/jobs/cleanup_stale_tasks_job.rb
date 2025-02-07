class CleanupStaleTasksJob < ApplicationJob
  queue_as :default

  def perform
    puts "ALAINA: Running stale task cleanup job"
    TaskAssignmentService.cleanup_stale_tasks
  end
end