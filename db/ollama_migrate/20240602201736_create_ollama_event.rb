class CreateOllamaEvent < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'vector'

    create_table :ollama_chunks, id: :uuid do |t|
      t.timestamps null: false, default: -> { 'NOW()' }, index: true

      t.string :data, null: false
      t.vector :embedding, dimensions: 1536, using: :ivfflat, opclass: :vector_ip_ops
      t.integer :token_count, null: false
    end

    create_table :ollama_conversations do |t|
      t.timestamps
    end

    create_enum :ollama_message_role, ["system", "assistant", "user"]
    create_table :ollama_messages do |t|
      t.enum :role, enum_type: :ollama_message_role, default: "system", null: false
      t.text :content
      t.references :ollama_conversation
      t.timestamps
    end

    create_join_table :ollama_chunks, :ollama_messages do |t|
      t.index [:ollama_chunk_id, :ollama_message_id], name: 'index_chunk_messages_on_chunk_id_and_message_id'
      t.index [:ollama_message_id, :ollama_chunk_id], name: 'index_chunk_messages_on_message_id_and_chunk_id'
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE ollama_chunks_messages REPLICA IDENTITY FULL;
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE ollama_chunks_messages REPLICA IDENTITY DEFAULT;
        SQL
      end
    end

    create_table :ollama_events do |t|
      t.json :data
      t.references :ollama_message
      t.references :ollama_conversation

      t.timestamps
    end
  end
end
