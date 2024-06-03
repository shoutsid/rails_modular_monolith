# == Schema Information
#
# Table name: ollama_messages
#
#  id                     :bigint           not null, primary key
#  content                :text
#  role                   :enum             default("system"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  ollama_conversation_id :bigint
#
# Indexes
#
#  index_ollama_messages_on_ollama_conversation_id  (ollama_conversation_id)
#
module Ollama
  class Message < ApplicationRecord
    include TransactionalOutbox::Outboxable
    has_many :events, foreign_key: :ollama_message_id
    belongs_to :conversation, foreign_key: :ollama_conversation_id

    has_and_belongs_to_many :chunks, foreign_key: :ollama_message_id, primary_key: :id

    enum :role, {
      system: "system", assistant: "assistant", user: "user"
    }, prefix: true

    after_create :create_chunk

    # TODO: Sync the chunk associated with this message upon update
    # after_update :sync_chunk

    def create_chunk
      Ollama::CreateChunkJob.perform_later(data: content, message_ids: [id])
    end
  end
end
