class AddProgressDataToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :progress_data, :jsonb
  end
end
