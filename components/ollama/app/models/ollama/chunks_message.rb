# frozen_string_literal: true

# == Schema Information
#
# Table name: ollama_chunks_messages
#
#  id                :bigint           not null, primary key
#  ollama_chunk_id   :uuid             not null
#  ollama_message_id :integer          not null
#
# Indexes
#
#  index_chunk_messages_on_chunk_id_and_message_id  (ollama_chunk_id,ollama_message_id)
#  index_chunk_messages_on_message_id_and_chunk_id  (ollama_message_id,ollama_chunk_id)
#
module Ollama
  # join chunk and message
  class ChunksMessage < ApplicationRecord
    belongs_to :ollama_chunk, class_name: 'Ollama::Chunk'
    belongs_to :ollama_message, class_name: 'Ollama::Message'
  end
end
