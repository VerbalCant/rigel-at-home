class CreateTaskDefinitions < ActiveRecord::Migration[7.1]
  def change
    create_table :task_definitions do |t|
      t.string :name
      t.text :description
      t.text :code
      t.jsonb :requirements

      t.timestamps
    end
  end
end
