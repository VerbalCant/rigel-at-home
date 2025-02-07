class AddTaskDefinitionIdToTasks < ActiveRecord::Migration[7.1]
  def change
    add_reference :tasks, :task_definition, null: false, foreign_key: true
  end
end
