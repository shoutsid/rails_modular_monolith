class OutboxCreateOllamaOutbox < ActiveRecord::Migration[7.0]
  def change
    create_table :ollama_outboxes do |t|
      t.uuid :identifier, null: false, index: { unique: true }
      t.string :event, null: false
      t.jsonb :payload
      t.string :aggregate, null: false
      t.uuid :aggregate_identifier, null: true, index: true

      t.timestamps
    end


    create_table :ollama_consumed_messages do |t|
      t.uuid :event_id
      t.string :aggregate


      t.integer :status, default: 0, null: false
      t.timestamps
    end

    add_index :ollama_consumed_messages, [:event_id, :aggregate], unique: true, name: 'index_ollama_consumed_messages_event_id_and_agg'
    add_index :ollama_consumed_messages, :status, name: 'index_ollama_consumed_messages_status'

    create_table :transactional_outbox_outboxes do |t|
      t.string :aggregate, null: false
      t.string :aggregate_identifier, null: false
      t.string :event, null: false
      t.uuid :identifier, null: false, index: true
      t.jsonb :payload

      t.timestamps
  end
  end
end
