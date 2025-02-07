class CreateAgents < ActiveRecord::Migration[7.1]
  def change
    create_table :agents do |t|
      t.string :name
      t.string :status
      t.datetime :last_seen_at
      t.jsonb :capabilities

      t.timestamps
    end
  end
end
