class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :name
      t.text :description
      t.text :code
      t.string :status
      t.references :agent, null: true, foreign_key: true
      t.jsonb :result
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end
