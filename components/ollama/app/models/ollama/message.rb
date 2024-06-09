# frozen_string_literal: true

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
  # Message model.
  class Message < ApplicationRecord
    include TransactionalOutbox::Outboxable
    has_many :events, foreign_key: :ollama_message_id
    belongs_to :conversation, foreign_key: :ollama_conversation_id

    has_many :chunks_messages, foreign_key: :ollama_message_id
    has_many :chunks, through: :chunks_messages, source: :ollama_chunk

    enum :role, {
      system: 'system', assistant: 'assistant', user: 'user'
    }, prefix: true

    after_create :create_chunk

    # TODO: Sync the chunk associated with this message upon update
    # after_update :sync_chunk

    def create_chunk
      chunks.build([data: content]).each(&:save!) if content.present?
    end
  end
end
